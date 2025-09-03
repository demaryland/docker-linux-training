# 🌐 Lesson 1: Container Networking Fundamentals - Making Containers Talk

*"From isolated islands to connected communities"*

Welcome to the world of container networking! You've learned to build and run individual containers, but real applications need containers to communicate with each other. In this lesson, we'll explore how Docker networking works and how to connect your containers like a pro.

## 🎯 What You'll Learn

- How Docker networking works under the hood
- Different types of Docker networks and when to use them
- Container name resolution and service discovery
- Port mapping and exposure strategies
- Connecting multiple containers securely

## 🏝️ The Container Island Problem

Imagine containers as islands in an ocean:
- **Without networking**: Each island is completely isolated
- **With networking**: Bridges connect islands, enabling communication
- **With proper networking**: Organized communities with clear addresses

### Default Container Behavior

```bash
# Run a container - it's isolated by default
docker run -d --name isolated-app nginx

# Try to access it - this won't work!
curl http://localhost:80  # ❌ Connection refused
```

## 🌉 Docker Network Types

Docker provides several network types, each serving different purposes:

### 1. Bridge Network (Default)
*Like a local neighborhood network*

```
Host Machine
├── docker0 bridge (172.17.0.1)
│   ├── Container A (172.17.0.2)
│   ├── Container B (172.17.0.3)
│   └── Container C (172.17.0.4)
└── External Network
```

### 2. Host Network
*Container shares the host's network directly*

```
Host Machine (192.168.1.100)
└── Container (uses 192.168.1.100 directly)
```

### 3. None Network
*Complete network isolation*

```
Container
└── No network interface (except loopback)
```

### 4. Custom Bridge Networks
*Your own private neighborhoods*

```
Custom Network "myapp-net"
├── Frontend Container
├── Backend Container
└── Database Container
```

## 🧪 Lab 1: Exploring Default Networking

Let's start by understanding how Docker networking works by default!

### Step 1: Examine Default Network

```bash
# List all Docker networks
docker network ls

# Inspect the default bridge network
docker network inspect bridge
```

You should see something like:
```
NETWORK ID     NAME      DRIVER    SCOPE
abcd1234       bridge    bridge    local
efgh5678       host      host      local
ijkl9012       none      null      local
```

### Step 2: Run Containers on Default Network

```bash
# Run first container
docker run -d --name web1 nginx

# Run second container
docker run -d --name web2 nginx

# Check their IP addresses
docker inspect web1 | grep IPAddress
docker inspect web2 | grep IPAddress
```

### Step 3: Test Container-to-Container Communication

```bash
# Try to ping from one container to another using IP
docker exec web1 ping -c 3 172.17.0.3  # Use actual IP from step 2

# Try to ping using container name (this won't work on default bridge!)
docker exec web1 ping -c 3 web2  # ❌ This will fail
```

**Important Discovery**: On the default bridge network, containers can communicate by IP but NOT by name!

### Step 4: Port Mapping for External Access

```bash
# Run container with port mapping
docker run -d -p 8080:80 --name web-accessible nginx

# Test external access
curl http://localhost:8080  # ✅ This works!

# Check port mapping
docker port web-accessible
```

## 🏗️ Custom Bridge Networks: The Better Way

Custom bridge networks solve the name resolution problem and provide better isolation.

### Creating Custom Networks

```bash
# Create a custom bridge network
docker network create myapp-network

# Inspect the new network
docker network inspect myapp-network

# List networks to see your new one
docker network ls
```

## 🧪 Lab 2: Building a Multi-Container Application

Let's build a real application with multiple containers that need to communicate!

### Step 1: Create Application Network

```bash
# Create a dedicated network for our application
docker network create webapp-network

# Verify it was created
docker network ls | grep webapp
```

### Step 2: Create a Simple Backend API

```bash
mkdir networking-demo
cd networking-demo

# Create a simple Node.js API
cat > backend.js << 'EOF'
const express = require('express');
const app = express();
const port = 3000;

app.use(express.json());

// In-memory data store
let users = [
  { id: 1, name: 'Alice', email: 'alice@example.com' },
  { id: 2, name: 'Bob', email: 'bob@example.com' }
];

app.get('/api/users', (req, res) => {
  res.json({
    message: 'Users from backend API',
    users: users,
    server: 'backend-api',
    timestamp: new Date().toISOString()
  });
});

app.get('/api/health', (req, res) => {
  res.json({ 
    status: 'healthy', 
    service: 'backend-api',
    network: 'webapp-network'
  });
});

app.listen(port, '0.0.0.0', () => {
  console.log(`🚀 Backend API running on port ${port}`);
  console.log(`🌐 Ready to serve requests from other containers`);
});
EOF

# Create package.json for backend
cat > package.json << 'EOF'
{
  "name": "backend-api",
  "version": "1.0.0",
  "description": "Backend API for networking demo",
  "main": "backend.js",
  "scripts": {
    "start": "node backend.js"
  },
  "dependencies": {
    "express": "^4.18.0"
  }
}
EOF

# Create Dockerfile for backend
cat > Dockerfile.backend << 'EOF'
FROM node:16-alpine
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY backend.js ./
EXPOSE 3000
CMD ["npm", "start"]
EOF
```

### Step 3: Create a Frontend Application

```bash
# Create a simple frontend that calls the backend
cat > frontend.js << 'EOF'
const express = require('express');
const app = express();
const port = 8080;

app.use(express.static('public'));

app.get('/', (req, res) => {
  res.send(`
    <html>
      <head>
        <title>Container Networking Demo</title>
        <style>
          body { 
            font-family: Arial, sans-serif; 
            max-width: 800px; 
            margin: 50px auto; 
            padding: 20px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
          }
          .container {
            background: rgba(255,255,255,0.1);
            padding: 30px;
            border-radius: 15px;
            backdrop-filter: blur(10px);
          }
          button {
            background: #4CAF50;
            color: white;
            padding: 10px 20px;
            border: none;
            border-radius: 5px;
            cursor: pointer;
            margin: 10px;
          }
          button:hover { background: #45a049; }
          #result {
            background: rgba(0,0,0,0.3);
            padding: 15px;
            border-radius: 5px;
            margin-top: 20px;
            white-space: pre-wrap;
          }
        </style>
      </head>
      <body>
        <div class="container">
          <h1>🌐 Container Networking Demo</h1>
          <p>This frontend container communicates with a backend container!</p>
          
          <button onclick="fetchUsers()">Get Users from Backend</button>
          <button onclick="checkHealth()">Check Backend Health</button>
          
          <div id="result"></div>
          
          <script>
            async function fetchUsers() {
              try {
                const response = await fetch('/api/users');
                const data = await response.json();
                document.getElementById('result').textContent = 
                  '✅ Success! Backend Response:\\n' + JSON.stringify(data, null, 2);
              } catch (error) {
                document.getElementById('result').textContent = 
                  '❌ Error: ' + error.message;
              }
            }
            
            async function checkHealth() {
              try {
                const response = await fetch('/api/health');
                const data = await response.json();
                document.getElementById('result').textContent = 
                  '✅ Backend Health Check:\\n' + JSON.stringify(data, null, 2);
              } catch (error) {
                document.getElementById('result').textContent = 
                  '❌ Health Check Failed: ' + error.message;
              }
            }
          </script>
        </div>
      </body>
    </html>
  `);
});

// Proxy API requests to backend
app.get('/api/*', async (req, res) => {
  try {
    const fetch = (await import('node-fetch')).default;
    // Use container name 'backend-api' to connect to backend
    const backendUrl = `http://backend-api:3000${req.path}`;
    console.log(`🔄 Proxying request to: ${backendUrl}`);
    
    const response = await fetch(backendUrl);
    const data = await response.json();
    res.json(data);
  } catch (error) {
    console.error('❌ Backend connection failed:', error.message);
    res.status(500).json({ 
      error: 'Backend connection failed', 
      details: error.message,
      attempted_url: `http://backend-api:3000${req.path}`
    });
  }
});

app.listen(port, '0.0.0.0', () => {
  console.log(`🌐 Frontend running on port ${port}`);
  console.log(`🔗 Will connect to backend at: http://backend-api:3000`);
});
EOF

# Create package.json for frontend
cat > package-frontend.json << 'EOF'
{
  "name": "frontend-app",
  "version": "1.0.0",
  "description": "Frontend app for networking demo",
  "main": "frontend.js",
  "scripts": {
    "start": "node frontend.js"
  },
  "dependencies": {
    "express": "^4.18.0",
    "node-fetch": "^3.3.0"
  }
}
EOF

# Create Dockerfile for frontend
cat > Dockerfile.frontend << 'EOF'
FROM node:16-alpine
WORKDIR /app
COPY package-frontend.json package.json
RUN npm install
COPY frontend.js ./
EXPOSE 8080
CMD ["npm", "start"]
EOF
```

### Step 4: Build the Images

```bash
# Build backend image
docker build -f Dockerfile.backend -t networking-backend .

# Build frontend image
docker build -f Dockerfile.frontend -t networking-frontend .

# Verify images were built
docker images | grep networking
```

### Step 5: Run Containers on Custom Network

```bash
# Run backend container on custom network
docker run -d \
  --name backend-api \
  --network webapp-network \
  networking-backend

# Run frontend container on custom network
docker run -d \
  --name frontend-app \
  --network webapp-network \
  -p 8080:8080 \
  networking-frontend

# Check that both containers are running
docker ps
```

### Step 6: Test Container Communication

```bash
# Test backend directly
docker exec backend-api curl -s http://localhost:3000/api/health

# Test frontend to backend communication
docker exec frontend-app curl -s http://backend-api:3000/api/users

# Test from your browser
echo "Open http://localhost:8080 in your browser and click the buttons!"
```

## 🔍 Understanding Name Resolution

On custom bridge networks, Docker provides automatic DNS resolution:

```bash
# From frontend container, resolve backend name
docker exec frontend-app nslookup backend-api

# From backend container, resolve frontend name
docker exec backend-api nslookup frontend-app

# Check network details
docker network inspect webapp-network
```

## 🧪 Lab 3: Network Isolation and Security

Let's explore how networks provide isolation and security!

### Step 1: Create Multiple Networks

```bash
# Create separate networks for different environments
docker network create frontend-network
docker network create backend-network
docker network create database-network

# List all networks
docker network ls
```

### Step 2: Create a Database Container

```bash
# Run a database on the backend network only
docker run -d \
  --name app-database \
  --network database-network \
  -e POSTGRES_DB=appdb \
  -e POSTGRES_USER=appuser \
  -e POSTGRES_PASSWORD=secret123 \
  postgres:13-alpine

# Verify it's running
docker ps | grep database
```

### Step 3: Test Network Isolation

```bash
# Try to connect to database from frontend (should fail)
docker exec frontend-app ping -c 2 app-database  # ❌ Should fail

# Connect backend to database network
docker network connect database-network backend-api

# Now backend can reach database
docker exec backend-api ping -c 2 app-database  # ✅ Should work
```

### Step 4: Multi-Network Container

```bash
# Check which networks backend-api is connected to
docker inspect backend-api | grep -A 10 "Networks"

# Backend is now on both webapp-network and database-network!
# This allows it to communicate with both frontend and database
```

## 🔧 Network Management Commands

### Essential Network Commands

```bash
# Create networks
docker network create my-network
docker network create --driver bridge my-bridge
docker network create --subnet=192.168.1.0/24 my-subnet

# Connect/disconnect containers
docker network connect my-network my-container
docker network disconnect my-network my-container

# Inspect networks
docker network inspect my-network
docker network ls

# Remove networks
docker network rm my-network
docker network prune  # Remove unused networks
```

### Network Drivers

```bash
# Bridge (default) - for single host
docker network create --driver bridge my-bridge

# Host - container uses host network directly
docker run --network host nginx

# None - no networking
docker run --network none alpine

# Overlay - for multi-host (Docker Swarm)
docker network create --driver overlay my-overlay
```

## 🧪 Lab 4: Advanced Networking Scenarios

Let's explore some advanced networking patterns!

### Step 1: Load Balancer Pattern

```bash
# Create a load balancer network
docker network create lb-network

# Run multiple backend instances
docker run -d --name backend-1 --network lb-network networking-backend
docker run -d --name backend-2 --network lb-network networking-backend
docker run -d --name backend-3 --network lb-network networking-backend

# Simple nginx load balancer config
cat > nginx.conf << 'EOF'
events {
    worker_connections 1024;
}

http {
    upstream backend {
        server backend-1:3000;
        server backend-2:3000;
        server backend-3:3000;
    }

    server {
        listen 80;
        location / {
            proxy_pass http://backend;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
        }
    }
}
EOF

# Run nginx load balancer
docker run -d \
  --name load-balancer \
  --network lb-network \
  -p 9090:80 \
  -v $(pwd)/nginx.conf:/etc/nginx/nginx.conf:ro \
  nginx

# Test load balancing
for i in {1..6}; do
  curl -s http://localhost:9090/api/health | grep server
done
```

### Step 2: Service Discovery Pattern

```bash
# Create service discovery network
docker network create service-network

# Run service registry (simple example with nginx)
docker run -d \
  --name service-registry \
  --network service-network \
  -p 8500:80 \
  nginx

# Services can discover each other by name
docker run -d \
  --name user-service \
  --network service-network \
  networking-backend

docker run -d \
  --name order-service \
  --network service-network \
  networking-backend

# Test service discovery
docker exec user-service ping -c 2 order-service
docker exec order-service ping -c 2 user-service
```

## 🔍 Troubleshooting Network Issues

### Common Network Problems and Solutions

#### 1. Container Can't Reach Another Container

```bash
# Check if containers are on the same network
docker inspect container1 | grep -A 5 "Networks"
docker inspect container2 | grep -A 5 "Networks"

# Check network connectivity
docker exec container1 ping container2

# Check DNS resolution
docker exec container1 nslookup container2
```

#### 2. Port Not Accessible from Host

```bash
# Check port mapping
docker port container-name

# Check if service is listening on all interfaces (0.0.0.0)
docker exec container-name netstat -tlnp

# Check firewall rules (if applicable)
sudo iptables -L
```

#### 3. Network Performance Issues

```bash
# Check network statistics
docker exec container-name cat /proc/net/dev

# Test network performance between containers
docker exec container1 ping -c 10 container2

# Check for network congestion
docker stats
```

## 🎯 Best Practices for Container Networking

### 1. Use Custom Networks

```bash
# ✅ Good: Use custom networks for better isolation
docker network create myapp-net
docker run --network myapp-net myapp

# ❌ Avoid: Using default bridge for multi-container apps
docker run myapp  # Uses default bridge
```

### 2. Meaningful Network Names

```bash
# ✅ Good: Descriptive network names
docker network create frontend-tier
docker network create backend-tier
docker network create database-tier

# ❌ Avoid: Generic names
docker network create net1
docker network create network
```

### 3. Network Segmentation

```bash
# ✅ Good: Separate networks for different tiers
docker network create public-web
docker network create private-api
docker network create secure-db

# Connect containers only to networks they need
docker run --network public-web frontend
docker run --network private-api --network secure-db backend
```

### 4. Security Considerations

```bash
# ✅ Good: Limit network access
docker network create --internal secure-internal

# ✅ Good: Use specific IP ranges
docker network create --subnet=10.0.1.0/24 controlled-net

# ✅ Good: Regular cleanup
docker network prune
```

## 🏆 Knowledge Check

Before moving on, make sure you can:
- [ ] Understand different Docker network types and their use cases
- [ ] Create custom bridge networks for container communication
- [ ] Connect containers to multiple networks
- [ ] Use container name resolution for service discovery
- [ ] Troubleshoot common networking issues

## 🚀 What's Next?

Great job! You've mastered the fundamentals of container networking. In the next lesson, we'll dive into [Advanced Networking Scenarios](02-advanced-networking.md) where you'll learn about complex networking patterns, security, and performance optimization.

## 📝 Quick Reference Card

```bash
# Network Management
docker network ls                              # List networks
docker network create network-name            # Create network
docker network inspect network-name           # Inspect network
docker network rm network-name                # Remove network

# Container Network Operations
docker run --network network-name image       # Run on specific network
docker network connect network-name container # Connect to network
docker network disconnect network-name container # Disconnect from network

# Network Types
docker run --network bridge image             # Default bridge
docker run --network host image               # Host networking
docker run --network none image               # No networking
```

---

*"In networking, as in life, communication is everything."* - Your containers are now ready to work together as a team! 🌐
