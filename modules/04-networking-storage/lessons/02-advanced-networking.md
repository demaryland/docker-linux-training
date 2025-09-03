# 🔌 Lesson 2: Advanced Networking Scenarios - Complex Networks Made Simple

*"From basic connections to enterprise-grade networking architectures"*

Welcome to advanced container networking! You've mastered the basics, now let's explore sophisticated networking patterns used in real-world applications. We'll cover load balancing, network security, performance optimization, and complex multi-tier architectures.

## 🎯 What You'll Learn

- Advanced port mapping and exposure strategies
- Load balancing and high availability patterns
- Network security and isolation techniques
- Performance optimization for container networks
- Multi-host networking concepts
- Troubleshooting complex network scenarios

## 🏗️ Advanced Port Mapping Strategies

Beyond basic port mapping, there are sophisticated patterns for exposing services.

### Dynamic Port Allocation

```bash
# Let Docker choose the port
docker run -d -P nginx  # Maps all exposed ports to random host ports

# Check what ports were assigned
docker port container-name

# Use in scripts
HOST_PORT=$(docker port container-name 80/tcp | cut -d: -f2)
echo "Service available at http://localhost:$HOST_PORT"
```

### Port Ranges and Multiple Services

```bash
# Map a range of ports
docker run -d -p 8000-8010:8000-8010 multi-service-app

# Map multiple specific ports
docker run -d \
  -p 80:80 \
  -p 443:443 \
  -p 8080:8080 \
  web-server

# Map to specific host interface
docker run -d -p 127.0.0.1:8080:80 nginx  # Only localhost
docker run -d -p 0.0.0.0:8080:80 nginx    # All interfaces
```

## 🧪 Lab 1: Building a Load-Balanced Web Application

Let's create a sophisticated load-balanced application with health checks and failover!

### Step 1: Create Application Components

```bash
mkdir advanced-networking
cd advanced-networking

# Create a backend service with instance identification
cat > backend-service.js << 'EOF'
const express = require('express');
const os = require('os');
const app = express();
const port = process.env.PORT || 3000;
const instanceId = process.env.INSTANCE_ID || os.hostname();

// Simulate some load and health status
let isHealthy = true;
let requestCount = 0;

app.use(express.json());

app.get('/api/data', (req, res) => {
  requestCount++;
  
  // Simulate occasional slow responses
  const delay = Math.random() * 100;
  
  setTimeout(() => {
    res.json({
      message: 'Data from backend service',
      instanceId: instanceId,
      requestCount: requestCount,
      timestamp: new Date().toISOString(),
      responseTime: `${delay.toFixed(2)}ms`
    });
  }, delay);
});

app.get('/health', (req, res) => {
  if (isHealthy) {
    res.json({
      status: 'healthy',
      instanceId: instanceId,
      uptime: process.uptime(),
      requestCount: requestCount
    });
  } else {
    res.status(503).json({
      status: 'unhealthy',
      instanceId: instanceId
    });
  }
});

// Endpoint to simulate health issues
app.post('/health/toggle', (req, res) => {
  isHealthy = !isHealthy;
  res.json({
    instanceId: instanceId,
    status: isHealthy ? 'healthy' : 'unhealthy'
  });
});

// Graceful shutdown
process.on('SIGTERM', () => {
  console.log(`Instance ${instanceId} shutting down gracefully`);
  process.exit(0);
});

app.listen(port, '0.0.0.0', () => {
  console.log(`🚀 Backend service ${instanceId} running on port ${port}`);
});
EOF

# Create package.json
cat > package.json << 'EOF'
{
  "name": "backend-service",
  "version": "1.0.0",
  "description": "Backend service for load balancing demo",
  "main": "backend-service.js",
  "scripts": {
    "start": "node backend-service.js"
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
COPY backend-service.js ./
EXPOSE 3000
HEALTHCHECK --interval=10s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:3000/health || exit 1
CMD ["npm", "start"]
EOF
```

### Step 2: Create Advanced Load Balancer Configuration

```bash
# Create nginx configuration with advanced features
cat > nginx.conf << 'EOF'
events {
    worker_connections 1024;
}

http {
    # Define upstream backend servers
    upstream backend_servers {
        # Load balancing method: round_robin (default), least_conn, ip_hash
        least_conn;
        
        # Backend servers with health checks
        server backend-1:3000 max_fails=3 fail_timeout=30s;
        server backend-2:3000 max_fails=3 fail_timeout=30s;
        server backend-3:3000 max_fails=3 fail_timeout=30s;
        
        # Backup server (only used when all others fail)
        server backend-backup:3000 backup;
    }
    
    # Enable gzip compression
    gzip on;
    gzip_types text/plain application/json application/javascript text/css;
    
    # Rate limiting
    limit_req_zone $binary_remote_addr zone=api:10m rate=10r/s;
    
    server {
        listen 80;
        
        # Health check endpoint for load balancer itself
        location /lb-health {
            access_log off;
            return 200 "Load balancer healthy\n";
            add_header Content-Type text/plain;
        }
        
        # API endpoints with rate limiting
        location /api/ {
            limit_req zone=api burst=20 nodelay;
            
            proxy_pass http://backend_servers;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            
            # Timeouts
            proxy_connect_timeout 5s;
            proxy_send_timeout 10s;
            proxy_read_timeout 10s;
            
            # Retry logic
            proxy_next_upstream error timeout invalid_header http_500 http_502 http_503;
        }
        
        # Static content or frontend
        location / {
            return 200 '
<!DOCTYPE html>
<html>
<head>
    <title>Advanced Load Balancer Demo</title>
    <style>
        body { font-family: Arial, sans-serif; max-width: 800px; margin: 50px auto; padding: 20px; }
        button { background: #4CAF50; color: white; padding: 10px 20px; border: none; border-radius: 5px; margin: 5px; cursor: pointer; }
        button:hover { background: #45a049; }
        .result { background: #f4f4f4; padding: 15px; margin: 10px 0; border-radius: 5px; white-space: pre-wrap; }
        .error { background: #ffebee; border-left: 5px solid #f44336; }
        .success { background: #e8f5e9; border-left: 5px solid #4caf50; }
    </style>
</head>
<body>
    <h1>🔌 Advanced Load Balancer Demo</h1>
    <p>This demonstrates advanced networking with load balancing, health checks, and failover.</p>
    
    <button onclick="testLoadBalancing()">Test Load Balancing</button>
    <button onclick="stressTest()">Stress Test (10 requests)</button>
    <button onclick="checkHealth()">Check Backend Health</button>
    
    <div id="results"></div>
    
    <script>
        async function testLoadBalancing() {
            const results = document.getElementById("results");
            results.innerHTML = "<div class=\"result\">Testing load balancing...</div>";
            
            try {
                const response = await fetch("/api/data");
                const data = await response.json();
                results.innerHTML = `<div class="result success">✅ Response from: ${data.instanceId}\\n${JSON.stringify(data, null, 2)}</div>`;
            } catch (error) {
                results.innerHTML = `<div class="result error">❌ Error: ${error.message}</div>`;
            }
        }
        
        async function stressTest() {
            const results = document.getElementById("results");
            results.innerHTML = "<div class=\"result\">Running stress test...</div>";
            
            const promises = [];
            for (let i = 0; i < 10; i++) {
                promises.push(fetch("/api/data").then(r => r.json()));
            }
            
            try {
                const responses = await Promise.all(promises);
                const instanceCounts = {};
                responses.forEach(r => {
                    instanceCounts[r.instanceId] = (instanceCounts[r.instanceId] || 0) + 1;
                });
                
                results.innerHTML = `<div class="result success">✅ Stress test complete!\\nLoad distribution:\\n${JSON.stringify(instanceCounts, null, 2)}</div>`;
            } catch (error) {
                results.innerHTML = `<div class="result error">❌ Stress test failed: ${error.message}</div>`;
            }
        }
        
        async function checkHealth() {
            const results = document.getElementById("results");
            results.innerHTML = "<div class=\"result\">Checking health...</div>";
            
            try {
                const response = await fetch("/lb-health");
                const text = await response.text();
                results.innerHTML = `<div class="result success">✅ Load balancer: ${text}</div>`;
            } catch (error) {
                results.innerHTML = `<div class="result error">❌ Health check failed: ${error.message}</div>`;
            }
        }
    </script>
</body>
</html>';
            add_header Content-Type text/html;
        }
    }
}
EOF
```

### Step 3: Create Network and Build Images

```bash
# Create network for load balancer demo
docker network create lb-demo-network

# Build backend image
docker build -f Dockerfile.backend -t advanced-backend .

# Verify image was built
docker images | grep advanced-backend
```

### Step 4: Deploy the Load-Balanced Application

```bash
# Start multiple backend instances
docker run -d \
  --name backend-1 \
  --network lb-demo-network \
  -e INSTANCE_ID=backend-1 \
  advanced-backend

docker run -d \
  --name backend-2 \
  --network lb-demo-network \
  -e INSTANCE_ID=backend-2 \
  advanced-backend

docker run -d \
  --name backend-3 \
  --network lb-demo-network \
  -e INSTANCE_ID=backend-3 \
  advanced-backend

# Start backup backend
docker run -d \
  --name backend-backup \
  --network lb-demo-network \
  -e INSTANCE_ID=backup-server \
  advanced-backend

# Start nginx load balancer
docker run -d \
  --name load-balancer \
  --network lb-demo-network \
  -p 8080:80 \
  -v $(pwd)/nginx.conf:/etc/nginx/nginx.conf:ro \
  nginx:alpine

# Check all containers are running
docker ps
```

### Step 5: Test Load Balancing and Failover

```bash
# Test load balancing
echo "Testing load balancing..."
for i in {1..6}; do
  curl -s http://localhost:8080/api/data | grep instanceId
done

# Test health checks
echo -e "\nChecking health status..."
curl -s http://localhost:8080/lb-health

# Simulate backend failure
echo -e "\nSimulating backend-1 failure..."
docker stop backend-1

# Test failover
echo "Testing failover..."
for i in {1..4}; do
  curl -s http://localhost:8080/api/data | grep instanceId
done

# Restart failed backend
echo -e "\nRestarting backend-1..."
docker start backend-1

# Wait for health check to pass
sleep 15

# Test recovery
echo "Testing recovery..."
for i in {1..4}; do
  curl -s http://localhost:8080/api/data | grep instanceId
done
```

## 🔒 Network Security and Isolation

### Network Segmentation Strategies

```bash
# Create security zones
docker network create --internal secure-internal
docker network create dmz-network
docker network create public-network

# Create networks with specific subnets
docker network create \
  --subnet=10.0.1.0/24 \
  --gateway=10.0.1.1 \
  frontend-tier

docker network create \
  --subnet=10.0.2.0/24 \
  --gateway=10.0.2.1 \
  backend-tier

docker network create \
  --subnet=10.0.3.0/24 \
  --gateway=10.0.3.1 \
  database-tier
```

## 🧪 Lab 2: Implementing Network Security Zones

Let's create a secure multi-tier application with proper network segmentation!

### Step 1: Create Security Architecture

```bash
mkdir secure-networking
cd secure-networking

# Create security zones
docker network create \
  --subnet=172.20.1.0/24 \
  public-zone

docker network create \
  --subnet=172.20.2.0/24 \
  application-zone

docker network create \
  --subnet=172.20.3.0/24 \
  --internal \
  database-zone
```

### Step 2: Create Secure Database Service

```bash
# Create database initialization script
cat > init-db.sql << 'EOF'
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO users (username, email) VALUES 
('alice', 'alice@example.com'),
('bob', 'bob@example.com'),
('charlie', 'charlie@example.com');
EOF

# Start secure database (only accessible from application zone)
docker run -d \
  --name secure-database \
  --network database-zone \
  -e POSTGRES_DB=secureapp \
  -e POSTGRES_USER=appuser \
  -e POSTGRES_PASSWORD=securepassword123 \
  -v $(pwd)/init-db.sql:/docker-entrypoint-initdb.d/init.sql:ro \
  postgres:13-alpine
```

### Step 3: Create Application Service with Database Access

```bash
# Create secure application service
cat > secure-app.js << 'EOF'
const express = require('express');
const { Pool } = require('pg');

const app = express();
const port = process.env.PORT || 3000;

// Database connection (only works from application zone)
const pool = new Pool({
  host: 'secure-database',
  port: 5432,
  database: 'secureapp',
  user: 'appuser',
  password: 'securepassword123',
});

app.use(express.json());

app.get('/api/users', async (req, res) => {
  try {
    const result = await pool.query('SELECT id, username, email, created_at FROM users');
    res.json({
      message: 'Secure data from database',
      users: result.rows,
      security: 'Database accessible only from application zone',
      timestamp: new Date().toISOString()
    });
  } catch (error) {
    res.status(500).json({
      error: 'Database connection failed',
      details: error.message,
      security_note: 'This is expected if not in application zone'
    });
  }
});

app.get('/api/health', (req, res) => {
  res.json({
    status: 'healthy',
    service: 'secure-application',
    zone: 'application-zone'
  });
});

app.get('/api/security-test', async (req, res) => {
  try {
    // Test database connectivity
    await pool.query('SELECT 1');
    res.json({
      database_access: 'allowed',
      zone: 'application-zone',
      security_level: 'high'
    });
  } catch (error) {
    res.status(403).json({
      database_access: 'denied',
      reason: 'Not in authorized network zone',
      security_level: 'enforced'
    });
  }
});

app.listen(port, '0.0.0.0', () => {
  console.log(`🔒 Secure application running on port ${port}`);
});
EOF

# Create package.json for secure app
cat > package-secure.json << 'EOF'
{
  "name": "secure-app",
  "version": "1.0.0",
  "description": "Secure application with network zones",
  "main": "secure-app.js",
  "scripts": {
    "start": "node secure-app.js"
  },
  "dependencies": {
    "express": "^4.18.0",
    "pg": "^8.8.0"
  }
}
EOF

# Create Dockerfile for secure app
cat > Dockerfile.secure << 'EOF'
FROM node:16-alpine
RUN apk add --no-cache curl
WORKDIR /app
COPY package-secure.json package.json
RUN npm install
COPY secure-app.js ./
EXPOSE 3000
HEALTHCHECK --interval=30s --timeout=3s --start-period=10s --retries=3 \
  CMD curl -f http://localhost:3000/api/health || exit 1
CMD ["npm", "start"]
EOF

# Build secure application
docker build -f Dockerfile.secure -t secure-app .
```

### Step 4: Deploy Secure Multi-Tier Application

```bash
# Start application service (connected to both application and database zones)
docker run -d \
  --name secure-app-service \
  --network application-zone \
  secure-app

# Connect application to database zone
docker network connect database-zone secure-app-service

# Start public-facing reverse proxy
cat > proxy.conf << 'EOF'
events {
    worker_connections 1024;
}

http {
    # Security headers
    add_header X-Frame-Options DENY;
    add_header X-Content-Type-Options nosniff;
    add_header X-XSS-Protection "1; mode=block";
    
    server {
        listen 80;
        
        # Only allow specific API endpoints
        location /api/users {
            proxy_pass http://secure-app-service:3000;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
        }
        
        location /api/health {
            proxy_pass http://secure-app-service:3000;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
        }
        
        # Block direct database access attempts
        location /api/security-test {
            return 403 "Access denied - security test endpoint blocked";
        }
        
        # Default deny
        location / {
            return 200 '
<!DOCTYPE html>
<html>
<head><title>Secure Application</title></head>
<body>
    <h1>🔒 Secure Multi-Tier Application</h1>
    <p>This application demonstrates network security zones.</p>
    <button onclick="fetch(\"/api/users\").then(r=>r.json()).then(d=>document.getElementById(\"result\").textContent=JSON.stringify(d,null,2))">Get Users (Allowed)</button>
    <button onclick="fetch(\"/api/security-test\").then(r=>r.text()).then(d=>document.getElementById(\"result\").textContent=d).catch(e=>document.getElementById(\"result\").textContent=\"Access denied: \"+e.message)">Security Test (Blocked)</button>
    <pre id="result"></pre>
</body>
</html>';
            add_header Content-Type text/html;
        }
    }
}
EOF

# Start reverse proxy in public zone
docker run -d \
  --name public-proxy \
  --network public-zone \
  -p 8080:80 \
  -v $(pwd)/proxy.conf:/etc/nginx/nginx.conf:ro \
  nginx:alpine

# Connect proxy to application zone
docker network connect application-zone public-proxy
```

### Step 5: Test Security Zones

```bash
# Test allowed access
echo "Testing allowed API access..."
curl -s http://localhost:8080/api/users | jq .

# Test blocked access
echo -e "\nTesting blocked security endpoint..."
curl -s http://localhost:8080/api/security-test

# Test network isolation - try to access database directly (should fail)
echo -e "\nTesting database isolation..."
docker run --rm \
  --network public-zone \
  postgres:13-alpine \
  psql -h secure-database -U appuser -d secureapp -c "SELECT 1;" 2>&1 || echo "✅ Database properly isolated"

# Test from application zone (should work)
echo -e "\nTesting database access from application zone..."
docker exec secure-app-service curl -s http://localhost:3000/api/security-test | jq .
```

## ⚡ Performance Optimization

### Connection Pooling and Keep-Alive

```bash
# Optimize nginx for performance
cat > performance-nginx.conf << 'EOF'
events {
    worker_connections 2048;
    use epoll;
    multi_accept on;
}

http {
    # Connection optimization
    keepalive_timeout 65;
    keepalive_requests 1000;
    
    # Upstream with connection pooling
    upstream backend_pool {
        keepalive 32;
        server backend-1:3000;
        server backend-2:3000;
    }
    
    server {
        listen 80;
        
        location / {
            proxy_pass http://backend_pool;
            proxy_http_version 1.1;
            proxy_set_header Connection "";
            proxy_set_header Host $host;
        }
    }
}
EOF
```

### Network Performance Monitoring

```bash
# Monitor network performance
docker stats --format "table {{.Container}}\t{{.NetIO}}\t{{.BlockIO}}"

# Test network latency between containers
docker exec container1 ping -c 10 container2

# Monitor network connections
docker exec container netstat -an | grep ESTABLISHED
```

## 🧪 Lab 3: Performance Testing and Optimization

Let's create a performance testing environment!

### Step 1: Create Performance Test Application

```bash
mkdir performance-testing
cd performance-testing

# Create a performance test backend
cat > perf-backend.js << 'EOF'
const express = require('express');
const app = express();
const port = process.env.PORT || 3000;

let requestCount = 0;
const startTime = Date.now();

app.get('/api/fast', (req, res) => {
  requestCount++;
  res.json({
    message: 'Fast response',
    requestNumber: requestCount,
    responseTime: '< 1ms'
  });
});

app.get('/api/slow', (req, res) => {
  requestCount++;
  // Simulate slow operation
  setTimeout(() => {
    res.json({
      message: 'Slow response',
      requestNumber: requestCount,
      responseTime: '100ms'
    });
  }, 100);
});

app.get('/api/stats', (req, res) => {
  const uptime = Date.now() - startTime;
  res.json({
    requestCount,
    uptime: `${uptime}ms`,
    requestsPerSecond: (requestCount / (uptime / 1000)).toFixed(2),
    instanceId: process.env.INSTANCE_ID || 'unknown'
  });
});

app.listen(port, '0.0.0.0', () => {
  console.log(`⚡ Performance backend ${process.env.INSTANCE_ID} running on port ${port}`);
});
EOF

# Create package.json
cat > package.json << 'EOF'
{
  "name": "perf-backend",
  "version": "1.0.0",
  "main": "perf-backend.js",
  "dependencies": {
    "express": "^4.18.0"
  }
}
EOF

# Create Dockerfile
cat > Dockerfile << 'EOF'
FROM node:16-alpine
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY perf-backend.js ./
EXPOSE 3000
CMD ["node", "perf-backend.js"]
EOF

# Build image
docker build -t perf-backend .
```

### Step 2: Create Performance Test Environment

```bash
# Create performance network
docker network create perf-network

# Start multiple backend instances
for i in {1..3}; do
  docker run -d \
    --name perf-backend-$i \
    --network perf-network \
    -e INSTANCE_ID=backend-$i \
    perf-backend
done

# Create optimized nginx config
cat > perf-nginx.conf << 'EOF'
events {
    worker_connections 2048;
    use epoll;
    multi_accept on;
}

http {
    # Performance optimizations
    sendfile on;
    tcp_nopush on;
    tcp_nodelay on;
    keepalive_timeout 65;
    keepalive_requests 1000;
    
    # Gzip compression
    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_types application/json text/plain;
    
    # Connection pooling
    upstream perf_backend {
        keepalive 32;
        server perf-backend-1:3000;
        server perf-backend-2:3000;
        server perf-backend-3:3000;
    }
    
    server {
        listen 80;
        
        location / {
            proxy_pass http://perf_backend;
            proxy_http_version 1.1;
            proxy_set_header Connection "";
            proxy_set_header Host $host;
            
            # Performance headers
            proxy_buffering on;
            proxy_buffer_size 4k;
            proxy_buffers 8 4k;
        }
    }
}
EOF

# Start optimized load balancer
docker run -d \
  --name perf-lb \
  --network perf-network \
  -p 8080:80 \
  -v $(pwd)/perf-nginx.conf:/etc/nginx/nginx.conf:ro \
  nginx:alpine
```

### Step 3: Run Performance Tests

```bash
# Install Apache Bench for testing (if not available)
# sudo apt-get install apache2-utils  # On Ubuntu/Debian
# brew install httpie  # On macOS

# Basic performance test
echo "Running basic performance test..."
curl -s http://localhost:8080/api/fast

# Stress test with concurrent requests
echo "Running stress test..."
ab -n 1000 -c 10 http://localhost:8080/api/fast

# Test slow endpoints
echo "Testing slow endpoints..."
ab -n 100 -c 5 http://localhost:8080/api/slow

# Check backend statistics
echo "Backend statistics:"
for i in {1..3}; do
  echo "Backend $i:"
  curl -s http://localhost:8080/api/stats | jq .
done
```

## 🔍 Advanced Troubleshooting

### Network Debugging Tools

```bash
# Install network debugging tools in containers
docker run -it --rm --network container:target-container nicolaka/netshoot

# Check network connectivity
docker exec container ping -c 3 target-host
docker exec container telnet target-host 80
docker exec container nslookup target-host

# Analyze network traffic
docker exec container tcpdump -i eth0 -n

# Check routing table
docker exec container ip route

# Check network interfaces
docker exec container ip addr show
```

### Performance Analysis

```bash
# Monitor network I/O
docker stats --format "table {{.Container}}\t{{.NetIO}}"

# Check connection states
docker exec container ss -tuln

# Monitor DNS resolution
docker exec container dig target-host

# Check network namespace
docker exec container ip netns list
```

## 🏆 Knowledge Check

Before moving on, make sure you can:
- [ ] Implement advanced load balancing with health checks
- [ ] Create secure network zones and isolation
- [ ] Optimize network performance for high-traffic applications
- [ ] Troubleshoot complex networking issues
- [ ] Design multi-tier network architectures

## 🚀 What's Next?

Excellent work! You've mastered advanced container networking. In the next lesson, we'll explore [Data Persistence with Volumes](03-volumes-storage.md) where you'll learn how to make your data survive container restarts and share data between containers.

## 📝 Quick Reference Card

```bash
# Advanced Port Mapping
docker run -d -P image                        # Dynamic port allocation
docker run -d -p 8000-8010:8000-8010 image   # Port ranges
docker run -d -p 127.0.0.1:8080:80 image     # Specific interface

# Network Security
docker network create --internal secure-net   # Internal-only network
docker network create --subnet=10.0.1.0/24 controlled-net  # Specific subnet

# Performance Optimization
docker run --network host image               # Host networking for performance
docker stats --format "table {{.Container}}\t{{.NetIO}}"  # Monitor network I/O

# Debugging
docker exec container ping target             # Test connectivity
docker exec container nslookup target         # DNS resolution
docker network inspect network-name           # Network details
```

---

*"Advanced networking is like conducting an orchestra - every component must work in harmony to create something beautiful."* - Your containers are now ready for enterprise-scale networking! 🔌
