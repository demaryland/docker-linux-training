# Lesson 1: Container Security Fundamentals

## Learning Objectives
By the end of this lesson, you will be able to:
- Understand the container security model and threat landscape
- Implement image security best practices
- Configure runtime security controls
- Scan images for vulnerabilities
- Apply the principle of least privilege to containers
- Secure container networks and storage

## Prerequisites
- Completed all previous modules
- Understanding of basic security concepts
- Familiarity with Linux security fundamentals

## Container Security Model

### Understanding the Attack Surface

Containers share the host kernel, creating unique security considerations:

1. **Host Security**: The container host is critical
2. **Image Security**: Vulnerabilities in base images affect all containers
3. **Runtime Security**: Container isolation and resource controls
4. **Network Security**: Container-to-container and external communication
5. **Data Security**: Persistent storage and secrets management

### Container vs VM Security

```
Traditional VM Security:
┌─────────────────┐ ┌─────────────────┐
│   Application   │ │   Application   │
├─────────────────┤ ├─────────────────┤
│   Guest OS      │ │   Guest OS      │
├─────────────────┤ ├─────────────────┤
│   Hypervisor    │ │   Hypervisor    │
├─────────────────┴─┴─────────────────┤
│           Host OS                   │
└─────────────────────────────────────┘

Container Security:
┌─────────────────┐ ┌─────────────────┐
│   Application   │ │   Application   │
├─────────────────┤ ├─────────────────┤
│   Container     │ │   Container     │
├─────────────────┴─┴─────────────────┤
│        Container Runtime            │
├─────────────────────────────────────┤
│           Host OS                   │
└─────────────────────────────────────┘
```

## Image Security Best Practices

### 1. Use Official and Minimal Base Images

```dockerfile
# Good: Official minimal image
FROM node:16-alpine

# Better: Distroless image
FROM gcr.io/distroless/nodejs:16

# Avoid: Large, outdated images
# FROM ubuntu:latest
```

### 2. Multi-Stage Builds for Security

```dockerfile
# Build stage
FROM node:16-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production

# Production stage
FROM gcr.io/distroless/nodejs:16
WORKDIR /app
COPY --from=builder /app/node_modules ./node_modules
COPY . .
USER 1001
CMD ["server.js"]
```

### 3. Minimize Attack Surface

```dockerfile
FROM alpine:3.18

# Install only necessary packages
RUN apk add --no-cache \
    nodejs \
    npm \
    && rm -rf /var/cache/apk/*

# Remove package managers in production
RUN apk del npm

# Create non-root user
RUN addgroup -g 1001 -S appgroup && \
    adduser -S appuser -u 1001 -G appgroup

# Set proper permissions
COPY --chown=appuser:appgroup . /app
WORKDIR /app

USER appuser
CMD ["node", "server.js"]
```

## Hands-on Lab 1: Image Security Scanning

Let's implement comprehensive image security practices.

### Step 1: Create Secure Application

Create `secure-app/Dockerfile.insecure`:

```dockerfile
# Intentionally insecure for demonstration
FROM ubuntu:18.04

# Install packages as root
RUN apt-get update && apt-get install -y \
    nodejs \
    npm \
    curl \
    wget \
    vim \
    sudo \
    ssh

# Add user to sudo group (bad practice)
RUN useradd -m appuser && \
    usermod -aG sudo appuser && \
    echo "appuser ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

WORKDIR /app
COPY . .

# Install dependencies as root
RUN npm install

# Expose unnecessary ports
EXPOSE 22 80 443 3000

# Run as root (bad practice)
CMD ["node", "server.js"]
```

Create `secure-app/Dockerfile.secure`:

```dockerfile
# Secure version
FROM node:16-alpine AS builder

WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production && \
    npm cache clean --force

FROM node:16-alpine AS runtime

# Create non-root user
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nodejs -u 1001 -G nodejs

# Set working directory
WORKDIR /app

# Copy dependencies from builder stage
COPY --from=builder /app/node_modules ./node_modules

# Copy application code
COPY --chown=nodejs:nodejs . .

# Remove unnecessary packages
RUN apk del npm

# Switch to non-root user
USER nodejs

# Expose only necessary port
EXPOSE 3000

# Use exec form and specific command
CMD ["node", "server.js"]
```

### Step 2: Create Security Scanning Script

Create `secure-app/scripts/security-scan.sh`:

```bash
#!/bin/bash

echo "=== Container Security Scanning ==="

IMAGE_NAME=${1:-"secure-app"}
DOCKERFILE=${2:-"Dockerfile.secure"}

# Build the image
echo "Building image: $IMAGE_NAME"
docker build -f $DOCKERFILE -t $IMAGE_NAME .

# 1. Scan for vulnerabilities (using Docker Scout if available)
echo "=== Vulnerability Scanning ==="
if command -v docker &> /dev/null; then
    if docker scout version &> /dev/null; then
        echo "Scanning with Docker Scout..."
        docker scout cves $IMAGE_NAME
    else
        echo "Docker Scout not available, using basic inspection..."
        docker history $IMAGE_NAME
    fi
fi

# 2. Check image configuration
echo "=== Image Configuration Analysis ==="
docker inspect $IMAGE_NAME | jq '.[0].Config' | tee image-config.json

# 3. Check for secrets in image
echo "=== Secrets Detection ==="
docker run --rm -v /var/run/docker.sock:/var/run/docker.sock \
    -v $(pwd):/tmp/scan \
    securecodewarrior/docker-security-scanning:latest \
    $IMAGE_NAME || echo "Security scanner not available"

# 4. Analyze layers
echo "=== Layer Analysis ==="
docker history --no-trunc $IMAGE_NAME

# 5. Check running container security
echo "=== Runtime Security Check ==="
CONTAINER_ID=$(docker run -d $IMAGE_NAME)
sleep 2

echo "Container processes:"
docker exec $CONTAINER_ID ps aux

echo "Container user:"
docker exec $CONTAINER_ID id

echo "Container capabilities:"
docker exec $CONTAINER_ID cat /proc/1/status | grep Cap

echo "Container filesystem:"
docker exec $CONTAINER_ID ls -la /

# Cleanup
docker stop $CONTAINER_ID
docker rm $CONTAINER_ID

echo "=== Security scan complete ==="
```

### Step 3: Create Application Files

Create `secure-app/package.json`:

```json
{
  "name": "secure-app",
  "version": "1.0.0",
  "main": "server.js",
  "dependencies": {
    "express": "^4.18.0",
    "helmet": "^6.0.0"
  }
}
```

Create `secure-app/server.js`:

```javascript
const express = require('express');
const helmet = require('helmet');

const app = express();
const port = process.env.PORT || 3000;

// Security middleware
app.use(helmet());

// Health check
app.get('/health', (req, res) => {
  res.json({ 
    status: 'healthy',
    timestamp: new Date().toISOString(),
    user: process.getuid(),
    pid: process.pid
  });
});

// Main endpoint
app.get('/', (req, res) => {
  res.json({
    message: 'Secure application running',
    security: {
      runningAsRoot: process.getuid() === 0,
      nodeVersion: process.version,
      platform: process.platform
    }
  });
});

app.listen(port, () => {
  console.log(`Secure app listening on port ${port}`);
  console.log(`Running as UID: ${process.getuid()}`);
});
```

### Step 4: Test Security Implementations

```bash
cd secure-app

# Make script executable
chmod +x scripts/security-scan.sh

# Scan insecure image
./scripts/security-scan.sh secure-app-insecure Dockerfile.insecure

# Scan secure image
./scripts/security-scan.sh secure-app-secure Dockerfile.secure

# Compare results
echo "=== Security Comparison ==="
echo "Insecure image size:"
docker images secure-app-insecure --format "table {{.Size}}"

echo "Secure image size:"
docker images secure-app-secure --format "table {{.Size}}"
```

## Runtime Security Controls

### 1. User and Privilege Management

```bash
# Run as non-root user
docker run --user 1001:1001 myapp

# Drop all capabilities
docker run --cap-drop ALL myapp

# Add only necessary capabilities
docker run --cap-drop ALL --cap-add NET_BIND_SERVICE myapp

# Prevent privilege escalation
docker run --security-opt no-new-privileges myapp
```

### 2. Filesystem Security

```bash
# Read-only root filesystem
docker run --read-only myapp

# Read-only with writable tmp
docker run --read-only --tmpfs /tmp myapp

# Specific volume mounts
docker run --read-only \
  --tmpfs /tmp \
  --tmpfs /var/cache \
  -v app_data:/app/data \
  myapp
```

### 3. Network Security

```bash
# Disable networking
docker run --network none myapp

# Custom network with isolation
docker network create --internal secure-network
docker run --network secure-network myapp
```

## Hands-on Lab 2: Runtime Security Hardening

Let's implement comprehensive runtime security controls.

### Step 1: Create Security Policy

Create `security-hardening/security-policy.yml`:

```yaml
# Security policy for containers
apiVersion: v1
kind: SecurityPolicy
metadata:
  name: container-security-policy
spec:
  # User security
  runAsNonRoot: true
  runAsUser: 1001
  runAsGroup: 1001
  
  # Filesystem security
  readOnlyRootFilesystem: true
  allowPrivilegeEscalation: false
  
  # Capabilities
  requiredDropCapabilities:
    - ALL
  allowedCapabilities:
    - NET_BIND_SERVICE
  
  # Resource limits
  resources:
    limits:
      memory: "512Mi"
      cpu: "500m"
    requests:
      memory: "256Mi"
      cpu: "250m"
```

### Step 2: Create Secure Docker Compose

Create `security-hardening/docker-compose.secure.yml`:

```yaml
version: '3.8'

services:
  secure-web:
    build: 
      context: .
      dockerfile: Dockerfile.secure
    ports:
      - "3000:3000"
    user: "1001:1001"
    read_only: true
    tmpfs:
      - /tmp:noexec,nosuid,size=100m
      - /var/cache:noexec,nosuid,size=50m
    cap_drop:
      - ALL
    cap_add:
      - NET_BIND_SERVICE
    security_opt:
      - no-new-privileges:true
      - apparmor:docker-default
    deploy:
      resources:
        limits:
          cpus: '0.5'
          memory: 512M
        reservations:
          cpus: '0.25'
          memory: 256M
    environment:
      - NODE_ENV=production
    networks:
      - secure-network
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "wget", "--quiet", "--tries=1", "--spider", "http://localhost:3000/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s

  secure-db:
    image: postgres:13-alpine
    user: "999:999"
    read_only: true
    tmpfs:
      - /tmp:noexec,nosuid,size=100m
      - /var/run/postgresql:noexec,nosuid,size=50m
    cap_drop:
      - ALL
    security_opt:
      - no-new-privileges:true
    environment:
      - POSTGRES_DB=secureapp
      - POSTGRES_USER=appuser
      - POSTGRES_PASSWORD_FILE=/run/secrets/db_password
    secrets:
      - db_password
    volumes:
      - db_data:/var/lib/postgresql/data
    networks:
      - secure-network
    deploy:
      resources:
        limits:
          cpus: '1'
          memory: 1G
        reservations:
          cpus: '0.5'
          memory: 512M

secrets:
  db_password:
    file: ./secrets/db_password.txt

volumes:
  db_data:
    driver: local

networks:
  secure-network:
    driver: bridge
    internal: true
    ipam:
      config:
        - subnet: 172.20.0.0/16
```

### Step 3: Create Security Testing Script

Create `security-hardening/scripts/security-test.sh`:

```bash
#!/bin/bash

echo "=== Runtime Security Testing ==="

# Start secure application
docker-compose -f docker-compose.secure.yml up -d

# Wait for services to start
sleep 10

# Test 1: Check user privileges
echo "=== User Privilege Test ==="
CONTAINER_ID=$(docker-compose -f docker-compose.secure.yml ps -q secure-web)

echo "Container running as user:"
docker exec $CONTAINER_ID id

echo "Attempting privilege escalation (should fail):"
docker exec $CONTAINER_ID sudo id 2>&1 || echo "✅ Privilege escalation blocked"

# Test 2: Check filesystem permissions
echo "=== Filesystem Security Test ==="
echo "Attempting to write to root filesystem (should fail):"
docker exec $CONTAINER_ID touch /test-file 2>&1 || echo "✅ Root filesystem is read-only"

echo "Attempting to write to /tmp (should succeed):"
docker exec $CONTAINER_ID touch /tmp/test-file && echo "✅ Writable tmpfs working"

# Test 3: Check capabilities
echo "=== Capabilities Test ==="
echo "Container capabilities:"
docker exec $CONTAINER_ID cat /proc/1/status | grep Cap

# Test 4: Check network isolation
echo "=== Network Security Test ==="
echo "Testing internal network connectivity:"
docker exec $CONTAINER_ID ping -c 1 secure-db && echo "✅ Internal connectivity working"

echo "Testing external network access (should be limited):"
docker exec $CONTAINER_ID ping -c 1 8.8.8.8 2>&1 || echo "✅ External access restricted"

# Test 5: Check resource limits
echo "=== Resource Limits Test ==="
echo "Container resource limits:"
docker exec $CONTAINER_ID cat /sys/fs/cgroup/memory/memory.limit_in_bytes
docker exec $CONTAINER_ID cat /sys/fs/cgroup/cpu/cpu.cfs_quota_us

# Test 6: Health check
echo "=== Health Check Test ==="
curl -f http://localhost:3000/health && echo "✅ Health check passed"

# Cleanup
echo "=== Cleanup ==="
docker-compose -f docker-compose.secure.yml down

echo "=== Security testing complete ==="
```

## Secrets Management

### 1. Docker Secrets

```yaml
version: '3.8'

services:
  app:
    image: myapp
    environment:
      - DB_PASSWORD_FILE=/run/secrets/db_password
      - API_KEY_FILE=/run/secrets/api_key
    secrets:
      - db_password
      - api_key

secrets:
  db_password:
    file: ./secrets/db_password.txt
  api_key:
    external: true
```

### 2. Environment Variable Security

```bash
# Bad: Secrets in environment variables
docker run -e DB_PASSWORD=secret123 myapp

# Good: Secrets from files
docker run -e DB_PASSWORD_FILE=/run/secrets/db_password myapp

# Good: External secret management
docker run -e VAULT_TOKEN_FILE=/run/secrets/vault_token myapp
```

### 3. Secrets in Application Code

```javascript
// Good: Read secrets from files
const fs = require('fs');

function getSecret(secretPath) {
  try {
    return fs.readFileSync(secretPath, 'utf8').trim();
  } catch (error) {
    console.error(`Failed to read secret from ${secretPath}:`, error);
    process.exit(1);
  }
}

const dbPassword = getSecret('/run/secrets/db_password');
const apiKey = getSecret('/run/secrets/api_key');
```

## Hands-on Lab 3: Comprehensive Security Implementation

Let's create a production-ready secure application.

### Step 1: Create Secure Multi-Service Application

Create `production-secure/docker-compose.yml`:

```yaml
version: '3.8'

services:
  # Reverse proxy with SSL termination
  nginx:
    image: nginx:alpine
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx/nginx.conf:/etc/nginx/nginx.conf:ro
      - ./nginx/ssl:/etc/nginx/ssl:ro
    depends_on:
      - api
    networks:
      - frontend
    user: "101:101"
    read_only: true
    tmpfs:
      - /var/cache/nginx:noexec,nosuid,size=50m
      - /var/run:noexec,nosuid,size=10m
    cap_drop:
      - ALL
    cap_add:
      - NET_BIND_SERVICE
    security_opt:
      - no-new-privileges:true
    restart: unless-stopped

  # Application server
  api:
    build:
      context: ./api
      dockerfile: Dockerfile.secure
    expose:
      - "3000"
    user: "1001:1001"
    read_only: true
    tmpfs:
      - /tmp:noexec,nosuid,size=100m
    cap_drop:
      - ALL
    security_opt:
      - no-new-privileges:true
    environment:
      - NODE_ENV=production
      - DB_HOST=database
      - DB_PASSWORD_FILE=/run/secrets/db_password
      - JWT_SECRET_FILE=/run/secrets/jwt_secret
    secrets:
      - db_password
      - jwt_secret
    depends_on:
      database:
        condition: service_healthy
    networks:
      - frontend
      - backend
    deploy:
      resources:
        limits:
          cpus: '1'
          memory: 512M
        reservations:
          cpus: '0.5'
          memory: 256M
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "wget", "--quiet", "--tries=1", "--spider", "http://localhost:3000/health"]
      interval: 30s
      timeout: 10s
      retries: 3

  # Database
  database:
    image: postgres:13-alpine
    user: "999:999"
    read_only: true
    tmpfs:
      - /tmp:noexec,nosuid,size=100m
      - /var/run/postgresql:noexec,nosuid,size=50m
    cap_drop:
      - ALL
    security_opt:
      - no-new-privileges:true
    environment:
      - POSTGRES_DB=prodapp
      - POSTGRES_USER=appuser
      - POSTGRES_PASSWORD_FILE=/run/secrets/db_password
    secrets:
      - db_password
    volumes:
      - db_data:/var/lib/postgresql/data
    networks:
      - backend
    deploy:
      resources:
        limits:
          cpus: '2'
          memory: 1G
        reservations:
          cpus: '1'
          memory: 512M
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U appuser"]
      interval: 30s
      timeout: 10s
      retries: 5

  # Security scanner (runs periodically)
  security-scanner:
    image: aquasec/trivy:latest
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock:ro
      - ./security-reports:/reports
    command: ["sh", "-c", "while true; do trivy image --format json --output /reports/scan-$(date +%Y%m%d-%H%M%S).json nginx:alpine; sleep 3600; done"]
    profiles:
      - security
    restart: unless-stopped

secrets:
  db_password:
    file: ./secrets/db_password.txt
  jwt_secret:
    file: ./secrets/jwt_secret.txt

volumes:
  db_data:
    driver: local

networks:
  frontend:
    driver: bridge
  backend:
    driver: bridge
    internal: true
```

### Step 2: Create Security Monitoring

Create `production-secure/scripts/security-monitor.sh`:

```bash
#!/bin/bash

echo "=== Security Monitoring Dashboard ==="

# Function to check container security
check_container_security() {
    local container=$1
    echo "Checking security for container: $container"
    
    # Check if running as root
    USER_ID=$(docker exec $container id -u 2>/dev/null)
    if [ "$USER_ID" = "0" ]; then
        echo "❌ $container is running as root"
    else
        echo "✅ $container is running as user $USER_ID"
    fi
    
    # Check capabilities
    CAPS=$(docker exec $container cat /proc/1/status 2>/dev/null | grep CapEff | awk '{print $2}')
    if [ "$CAPS" = "0000000000000000" ]; then
        echo "✅ $container has no capabilities"
    else
        echo "⚠️  $container has capabilities: $CAPS"
    fi
    
    # Check read-only filesystem
    if docker exec $container touch /test-readonly 2>/dev/null; then
        echo "❌ $container filesystem is writable"
        docker exec $container rm -f /test-readonly 2>/dev/null
    else
        echo "✅ $container filesystem is read-only"
    fi
    
    echo "---"
}

# Get all running containers
CONTAINERS=$(docker ps --format "{{.Names}}")

for container in $CONTAINERS; do
    check_container_security $container
done

# Check for security updates
echo "=== Security Updates Check ==="
docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.CreatedAt}}" | head -10

# Check for exposed ports
echo "=== Exposed Ports Check ==="
docker ps --format "table {{.Names}}\t{{.Ports}}"

# Check resource usage
echo "=== Resource Usage ==="
docker stats --no-stream --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.MemPerc}}"

echo "=== Security monitoring complete ==="
```

## Security Best Practices Summary

### 1. Image Security
- Use official, minimal base images
- Scan images for vulnerabilities
- Keep images updated
- Use multi-stage builds
- Remove unnecessary packages

### 2. Runtime Security
- Run as non-root user
- Use read-only filesystems
- Drop unnecessary capabilities
- Implement resource limits
- Enable security options

### 3. Network Security
- Use custom networks
- Implement network segmentation
- Limit exposed ports
- Use TLS for communication

### 4. Secrets Management
- Never embed secrets in images
- Use Docker secrets or external systems
- Rotate secrets regularly
- Limit secret access

### 5. Monitoring and Compliance
- Implement security scanning
- Monitor runtime behavior
- Audit access and changes
- Maintain security documentation

## Summary

In this lesson, you learned:
- Container security fundamentals and threat model
- Image security best practices and vulnerability scanning
- Runtime security controls and hardening techniques
- Secrets management strategies
- Security monitoring and compliance practices

## Next Steps
- Practice implementing security controls
- Set up automated security scanning
- Create security policies for your organization
- Move on to Lesson 2: Monitoring and Logging

## Additional Resources
- [Docker Security Best Practices](https://docs.docker.com/engine/security/)
- [CIS Docker Benchmark](https://www.cisecurity.org/benchmark/docker)
- [NIST Container Security Guide](https://csrc.nist.gov/publications/detail/sp/800-190/final)
- [OWASP Container Security](https://owasp.org/www-project-container-security/)
