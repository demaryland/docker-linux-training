# Lesson 5: Troubleshooting Networks and Storage

## Learning Objectives
By the end of this lesson, you will be able to:
- Diagnose common Docker networking issues
- Troubleshoot storage and volume problems
- Use Docker debugging tools effectively
- Implement monitoring and logging strategies
- Resolve connectivity and performance issues

## Prerequisites
- Completed previous networking and storage lessons
- Understanding of Docker networks and volumes
- Basic knowledge of networking concepts

## Common Networking Issues

### 1. Container Connectivity Problems

**Symptom**: Containers cannot communicate with each other
**Common Causes**:
- Containers on different networks
- Port binding issues
- Firewall restrictions
- DNS resolution problems

### 2. Port Binding Conflicts

**Symptom**: "Port already in use" errors
**Common Causes**:
- Multiple containers trying to bind to same port
- Host services using the port
- Previous container instances not properly cleaned up

### 3. DNS Resolution Issues

**Symptom**: Cannot resolve container names
**Common Causes**:
- Containers not on same user-defined network
- Incorrect container naming
- Network configuration problems

## Hands-on Lab 1: Diagnosing Network Issues

Let's create a scenario with network problems and learn to diagnose them.

### Step 1: Create a Problematic Setup

```bash
# Create containers with connectivity issues
docker run -d --name web-server nginx:alpine
docker run -d --name app-server node:alpine sleep 3600

# Try to connect from app to web (this will fail)
docker exec app-server wget -qO- http://web-server
```

### Step 2: Investigate the Problem

```bash
# Check container networks
docker inspect web-server | grep NetworkMode
docker inspect app-server | grep NetworkMode

# List networks
docker network ls

# Inspect the default bridge network
docker network inspect bridge
```

### Step 3: Diagnose with Docker Tools

```bash
# Check container connectivity
docker exec app-server ping web-server

# Check DNS resolution
docker exec app-server nslookup web-server

# Check network interfaces
docker exec web-server ip addr show
```

### Step 4: Fix the Issue

```bash
# Create a custom network
docker network create app-network

# Connect both containers to the network
docker network connect app-network web-server
docker network connect app-network app-server

# Test connectivity again
docker exec app-server wget -qO- http://web-server
```

## Storage Troubleshooting

### 1. Volume Mount Issues

**Common Problems**:
- Permission denied errors
- Volume not persisting data
- Incorrect mount paths
- SELinux context issues (on RHEL/CentOS)

### 2. Disk Space Problems

**Symptoms**:
- "No space left on device" errors
- Container startup failures
- Performance degradation

### 3. Data Corruption

**Causes**:
- Improper container shutdown
- Multiple containers writing to same volume
- Host system issues

## Hands-on Lab 2: Storage Troubleshooting

### Step 1: Create Storage Issues

```bash
# Create a container with permission issues
mkdir -p /tmp/restricted-data
sudo chmod 700 /tmp/restricted-data
sudo chown root:root /tmp/restricted-data

docker run -d --name permission-test \
  -v /tmp/restricted-data:/data \
  alpine:latest sleep 3600

# Try to write to the volume (this may fail)
docker exec permission-test touch /data/test.txt
```

### Step 2: Diagnose Permission Issues

```bash
# Check container user
docker exec permission-test id

# Check volume permissions
docker exec permission-test ls -la /data

# Check host permissions
ls -la /tmp/restricted-data
```

### Step 3: Fix Permission Issues

```bash
# Option 1: Fix host permissions
sudo chmod 755 /tmp/restricted-data
sudo chown $(id -u):$(id -g) /tmp/restricted-data

# Option 2: Run container as root
docker run -d --name permission-fixed \
  --user root \
  -v /tmp/restricted-data:/data \
  alpine:latest sleep 3600

# Test the fix
docker exec permission-fixed touch /data/test.txt
docker exec permission-fixed ls -la /data
```

## Debugging Tools and Techniques

### 1. Docker Logs

```bash
# View container logs
docker logs container-name

# Follow logs in real-time
docker logs -f container-name

# Show timestamps
docker logs -t container-name

# Limit log output
docker logs --tail 50 container-name
```

### 2. Container Inspection

```bash
# Get detailed container information
docker inspect container-name

# Extract specific information
docker inspect --format='{{.NetworkSettings.IPAddress}}' container-name
docker inspect --format='{{.Mounts}}' container-name
```

### 3. Resource Monitoring

```bash
# Monitor container resource usage
docker stats

# Monitor specific container
docker stats container-name

# Get resource usage without streaming
docker stats --no-stream
```

### 4. Network Debugging

```bash
# List all networks
docker network ls

# Inspect network details
docker network inspect network-name

# Check which containers are on a network
docker network inspect bridge --format='{{range .Containers}}{{.Name}} {{end}}'
```

## Hands-on Lab 3: Comprehensive Debugging

Let's create a complex application with multiple issues and debug them systematically.

### Step 1: Deploy Problematic Application

Create a `docker-compose.yml` with intentional issues:

```yaml
version: '3.8'
services:
  web:
    image: nginx:alpine
    ports:
      - "8080:80"
    volumes:
      - ./html:/usr/share/nginx/html
    depends_on:
      - api
    environment:
      - API_URL=http://api:3000

  api:
    image: node:alpine
    ports:
      - "3000:3000"
    volumes:
      - ./app:/app
      - /app/node_modules
    working_dir: /app
    command: npm start
    environment:
      - DB_HOST=database
      - DB_PORT=5432

  database:
    image: postgres:13
    environment:
      - POSTGRES_DB=myapp
      - POSTGRES_USER=user
      # Missing password - intentional issue
    volumes:
      - db_data:/var/lib/postgresql/data

volumes:
  db_data:
```

### Step 2: Create Application Files

```bash
# Create directories
mkdir -p html app

# Create simple HTML
cat > html/index.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>Debug Demo</title>
</head>
<body>
    <h1>Debugging Demo App</h1>
    <div id="data">Loading...</div>
    <script>
        fetch('/api/data')
            .then(response => response.json())
            .then(data => {
                document.getElementById('data').innerHTML = JSON.stringify(data);
            })
            .catch(error => {
                document.getElementById('data').innerHTML = 'Error: ' + error;
            });
    </script>
</body>
</html>
EOF

# Create simple Node.js app
cat > app/package.json << 'EOF'
{
  "name": "debug-api",
  "version": "1.0.0",
  "main": "server.js",
  "scripts": {
    "start": "node server.js"
  },
  "dependencies": {
    "express": "^4.18.0",
    "pg": "^8.8.0"
  }
}
EOF

cat > app/server.js << 'EOF'
const express = require('express');
const { Client } = require('pg');

const app = express();
const port = 3000;

const client = new Client({
  host: process.env.DB_HOST,
  port: process.env.DB_PORT,
  database: process.env.DB_NAME || 'myapp',
  user: process.env.DB_USER || 'user',
  password: process.env.DB_PASSWORD || 'password'
});

app.get('/api/data', async (req, res) => {
  try {
    await client.connect();
    const result = await client.query('SELECT NOW() as current_time');
    res.json(result.rows[0]);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.listen(port, () => {
  console.log(`API server running on port ${port}`);
});
EOF
```

### Step 3: Deploy and Debug

```bash
# Try to start the application
docker-compose up -d

# Check container status
docker-compose ps

# Check logs for issues
docker-compose logs web
docker-compose logs api
docker-compose logs database
```

### Step 4: Systematic Debugging

```bash
# 1. Check database issues
docker-compose logs database | grep -i error

# 2. Fix database password
# Edit docker-compose.yml to add POSTGRES_PASSWORD

# 3. Check API connectivity
docker-compose exec api ping database

# 4. Check if API can connect to database
docker-compose exec api nc -zv database 5432

# 5. Test API endpoint
docker-compose exec web curl http://api:3000/api/data

# 6. Check web server configuration
docker-compose exec web nginx -t
```

## Performance Troubleshooting

### 1. Identifying Bottlenecks

```bash
# Monitor resource usage
docker stats --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}\t{{.BlockIO}}"

# Check container processes
docker exec container-name top

# Monitor disk I/O
docker exec container-name iostat -x 1
```

### 2. Network Performance

```bash
# Test network latency between containers
docker exec container1 ping -c 10 container2

# Test bandwidth
docker exec container1 iperf3 -s &
docker exec container2 iperf3 -c container1
```

### 3. Storage Performance

```bash
# Test disk performance
docker exec container-name dd if=/dev/zero of=/tmp/test bs=1M count=100

# Check volume mount performance
docker exec container-name time ls -la /mounted/volume
```

## Monitoring and Logging Best Practices

### 1. Centralized Logging

```bash
# Configure logging driver
docker run -d \
  --log-driver=json-file \
  --log-opt max-size=10m \
  --log-opt max-file=3 \
  nginx:alpine
```

### 2. Health Checks

Add health checks to your containers:

```dockerfile
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost/ || exit 1
```

### 3. Monitoring Setup

```yaml
version: '3.8'
services:
  app:
    image: myapp:latest
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:3000/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s
```

## Common Troubleshooting Commands

### Quick Reference

```bash
# Container debugging
docker ps -a                          # List all containers
docker logs -f container-name         # Follow logs
docker exec -it container-name sh     # Interactive shell
docker inspect container-name         # Detailed info

# Network debugging
docker network ls                     # List networks
docker network inspect network-name  # Network details
docker port container-name           # Port mappings

# Storage debugging
docker volume ls                      # List volumes
docker volume inspect volume-name    # Volume details
docker system df                     # Disk usage

# System debugging
docker system info                   # System information
docker system events                 # Real-time events
docker system prune                  # Clean up resources
```

## Hands-on Lab 4: Creating a Debugging Toolkit

Let's create a debugging container with useful tools.

### Step 1: Create Debug Dockerfile

```dockerfile
FROM alpine:latest

# Install debugging tools
RUN apk add --no-cache \
    curl \
    wget \
    netcat-openbsd \
    bind-tools \
    tcpdump \
    strace \
    htop \
    iotop \
    iperf3 \
    postgresql-client \
    mysql-client \
    redis

# Add useful aliases
RUN echo 'alias ll="ls -la"' >> /root/.bashrc && \
    echo 'alias ports="netstat -tuln"' >> /root/.bashrc

WORKDIR /debug
CMD ["sh"]
```

### Step 2: Build and Use Debug Container

```bash
# Build the debug image
docker build -t debug-toolkit .

# Use it to debug other containers
docker run -it --rm \
  --network container:target-container \
  debug-toolkit

# Or attach to existing network
docker run -it --rm \
  --network app-network \
  debug-toolkit
```

## Troubleshooting Checklist

When facing Docker issues, follow this systematic approach:

### 1. Gather Information
- [ ] Check container status (`docker ps -a`)
- [ ] Review logs (`docker logs container-name`)
- [ ] Inspect container configuration (`docker inspect`)
- [ ] Check resource usage (`docker stats`)

### 2. Network Issues
- [ ] Verify containers are on same network
- [ ] Check port bindings and conflicts
- [ ] Test DNS resolution between containers
- [ ] Verify firewall and security group settings

### 3. Storage Issues
- [ ] Check volume mounts and permissions
- [ ] Verify disk space availability
- [ ] Test file system accessibility
- [ ] Review SELinux/AppArmor contexts

### 4. Performance Issues
- [ ] Monitor CPU and memory usage
- [ ] Check disk I/O performance
- [ ] Test network latency and bandwidth
- [ ] Review container resource limits

### 5. Application Issues
- [ ] Verify environment variables
- [ ] Check application configuration
- [ ] Test service dependencies
- [ ] Review application logs

## Best Practices for Prevention

### 1. Proactive Monitoring
- Implement health checks
- Set up log aggregation
- Monitor resource usage
- Use container orchestration tools

### 2. Proper Configuration
- Use explicit network configurations
- Set appropriate resource limits
- Implement proper error handling
- Use configuration management

### 3. Testing and Validation
- Test in staging environments
- Validate configurations before deployment
- Use automated testing
- Implement rollback procedures

## Summary

In this lesson, you learned:
- How to diagnose common Docker networking and storage issues
- Essential debugging tools and techniques
- Systematic approaches to troubleshooting
- Performance monitoring and optimization
- Best practices for preventing issues

## Next Steps
- Practice with the troubleshooting labs
- Set up monitoring for your applications
- Create your own debugging toolkit
- Move on to Module 5: Docker Compose

## Additional Resources
- [Docker Troubleshooting Guide](https://docs.docker.com/config/troubleshooting/)
- [Container Networking Troubleshooting](https://docs.docker.com/network/troubleshooting/)
- [Docker Storage Troubleshooting](https://docs.docker.com/storage/troubleshooting/)
- [Performance Tuning Best Practices](https://docs.docker.com/config/containers/resource_constraints/)
