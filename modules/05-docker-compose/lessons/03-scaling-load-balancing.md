# Lesson 3: Scaling and Load Balancing

## Learning Objectives
By the end of this lesson, you will be able to:
- Scale services horizontally using Docker Compose
- Implement load balancing strategies
- Configure health checks for reliable scaling
- Monitor and manage scaled services
- Implement auto-scaling patterns
- Handle session management in scaled environments

## Prerequisites
- Completed previous Docker Compose lessons
- Understanding of load balancing concepts
- Basic knowledge of web application architecture

## Introduction to Scaling

Scaling is the process of adjusting your application's capacity to handle varying loads. There are two main types:

### Vertical Scaling (Scale Up)
- Adding more power (CPU, RAM) to existing machines
- Limited by hardware constraints
- Single point of failure

### Horizontal Scaling (Scale Out)
- Adding more machines/containers to the pool
- Better fault tolerance
- More complex to manage
- **This is what we'll focus on with Docker Compose**

## Basic Service Scaling

### Simple Scaling Command

```bash
# Scale a service to 3 instances
docker-compose up -d --scale web=3

# Scale multiple services
docker-compose up -d --scale web=3 --scale api=2

# Scale down
docker-compose up -d --scale web=1
```

### Scaling in Compose File

```yaml
version: '3.8'

services:
  web:
    image: nginx:alpine
    ports:
      - "80-85:80"  # Port range for multiple instances
    deploy:
      replicas: 3   # Default number of replicas

  api:
    build: ./api
    deploy:
      replicas: 2
```

## Hands-on Lab 1: Basic Web Service Scaling

Let's create a scalable web application with load balancing.

### Step 1: Create Application Structure

```bash
mkdir scalable-web-app
cd scalable-web-app
mkdir app nginx-lb
```

### Step 2: Create Simple Web Application

Create `app/Dockerfile`:

```dockerfile
FROM node:16-alpine

WORKDIR /app

# Install dependencies
COPY package*.json ./
RUN npm install

# Copy source code
COPY . .

# Create non-root user
RUN addgroup -g 1001 -S nodejs
RUN adduser -S nodejs -u 1001
USER nodejs

EXPOSE 3000
CMD ["node", "server.js"]
```

Create `app/package.json`:

```json
{
  "name": "scalable-app",
  "version": "1.0.0",
  "main": "server.js",
  "dependencies": {
    "express": "^4.18.0",
    "os": "^0.1.2"
  }
}
```

Create `app/server.js`:

```javascript
const express = require('express');
const os = require('os');

const app = express();
const port = process.env.PORT || 3000;
const instanceId = process.env.HOSTNAME || os.hostname();

// Middleware to add instance info
app.use((req, res, next) => {
  res.setHeader('X-Instance-ID', instanceId);
  next();
});

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({
    status: 'healthy',
    instance: instanceId,
    timestamp: new Date().toISOString(),
    uptime: process.uptime()
  });
});

// Main endpoint
app.get('/', (req, res) => {
  res.json({
    message: 'Hello from scalable app!',
    instance: instanceId,
    hostname: os.hostname(),
    platform: os.platform(),
    arch: os.arch(),
    loadavg: os.loadavg(),
    freemem: os.freemem(),
    totalmem: os.totalmem(),
    timestamp: new Date().toISOString()
  });
});

// Simulate some work
app.get('/work', (req, res) => {
  const start = Date.now();
  const duration = parseInt(req.query.duration) || 1000;
  
  // Simulate CPU work
  while (Date.now() - start < duration) {
    Math.random();
  }
  
  res.json({
    message: 'Work completed',
    instance: instanceId,
    duration: duration,
    actualDuration: Date.now() - start
  });
});

// Error endpoint for testing
app.get('/error', (req, res) => {
  res.status(500).json({
    error: 'Simulated error',
    instance: instanceId
  });
});

app.listen(port, () => {
  console.log(`Server running on port ${port}, instance: ${instanceId}`);
});
```

### Step 3: Create Load Balancer Configuration

Create `nginx-lb/nginx.conf`:

```nginx
upstream app_servers {
    # Docker Compose will resolve these to actual container IPs
    server app:3000 max_fails=3 fail_timeout=30s;
    # Additional servers will be added automatically when scaling
}

server {
    listen 80;
    
    # Load balancer status page
    location /lb-status {
        stub_status on;
        access_log off;
        allow 127.0.0.1;
        allow 10.0.0.0/8;
        allow 172.16.0.0/12;
        allow 192.168.0.0/16;
        deny all;
    }
    
    # Health check for load balancer
    location /lb-health {
        access_log off;
        return 200 "Load Balancer OK\n";
        add_header Content-Type text/plain;
    }
    
    # Proxy to application servers
    location / {
        proxy_pass http://app_servers;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        
        # Health check settings
        proxy_connect_timeout 5s;
        proxy_send_timeout 10s;
        proxy_read_timeout 10s;
        
        # Add load balancer info
        add_header X-Load-Balancer nginx;
    }
}
```

### Step 4: Create Docker Compose Configuration

Create `docker-compose.yml`:

```yaml
version: '3.8'

services:
  # Load Balancer
  nginx:
    image: nginx:alpine
    ports:
      - "80:80"
    volumes:
      - ./nginx-lb/nginx.conf:/etc/nginx/conf.d/default.conf
    depends_on:
      - app
    networks:
      - app-network
    restart: unless-stopped

  # Scalable Application
  app:
    build: ./app
    expose:
      - "3000"
    networks:
      - app-network
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "wget", "--quiet", "--tries=1", "--spider", "http://localhost:3000/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s

networks:
  app-network:
    driver: bridge
```

### Step 5: Test Basic Scaling

```bash
# Start with single instance
docker-compose up -d

# Test the application
curl http://localhost/
curl http://localhost/health

# Scale to 3 instances
docker-compose up -d --scale app=3

# Check running containers
docker-compose ps

# Test load balancing (run multiple times)
for i in {1..10}; do
  curl -s http://localhost/ | grep instance
done
```

## Advanced Load Balancing with HAProxy

For more sophisticated load balancing, let's use HAProxy.

### Step 1: Create HAProxy Configuration

Create `haproxy/haproxy.cfg`:

```cfg
global
    daemon
    log stdout local0 info

defaults
    mode http
    timeout connect 5000ms
    timeout client 50000ms
    timeout server 50000ms
    option httplog
    log global

# Statistics page
stats enable
stats uri /stats
stats refresh 30s
stats admin if TRUE

# Frontend
frontend web_frontend
    bind *:80
    
    # Health check endpoint
    acl is_health path_beg /lb-health
    http-request return status 200 content-type text/plain string "HAProxy OK" if is_health
    
    # Route to backend
    default_backend web_servers

# Backend with different load balancing algorithms
backend web_servers
    balance roundrobin
    option httpchk GET /health
    
    # Server template for dynamic scaling
    server-template app- 10 app:3000 check resolvers docker init-addr none
    
# Alternative backend with different algorithm
backend web_servers_leastconn
    balance leastconn
    option httpchk GET /health
    server-template app- 10 app:3000 check resolvers docker init-addr none

# Resolver for Docker DNS
resolvers docker
    nameserver dns1 127.0.0.11:53
    resolve_retries 3
    timeout resolve 1s
    timeout retry 1s
    hold other 10s
    hold refused 10s
    hold nx 10s
    hold timeout 10s
    hold valid 10s
    hold obsolete 10s
```

### Step 2: Create HAProxy Compose Configuration

Create `docker-compose.haproxy.yml`:

```yaml
version: '3.8'

services:
  # HAProxy Load Balancer
  haproxy:
    image: haproxy:2.4-alpine
    ports:
      - "80:80"
      - "8404:8404"  # Stats page
    volumes:
      - ./haproxy/haproxy.cfg:/usr/local/etc/haproxy/haproxy.cfg:ro
    depends_on:
      - app
    networks:
      - app-network
    restart: unless-stopped

  # Scalable Application
  app:
    build: ./app
    expose:
      - "3000"
    networks:
      - app-network
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "wget", "--quiet", "--tries=1", "--spider", "http://localhost:3000/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s

networks:
  app-network:
    driver: bridge
```

### Step 3: Test HAProxy Load Balancing

```bash
# Start with HAProxy
docker-compose -f docker-compose.haproxy.yml up -d

# Scale the application
docker-compose -f docker-compose.haproxy.yml up -d --scale app=5

# Test load balancing
for i in {1..20}; do
  curl -s http://localhost/ | jq -r '.instance'
done

# View HAProxy stats
# Open http://localhost:8404/stats in browser
```

## Hands-on Lab 2: Auto-Scaling Web Service

Let's create a more sophisticated setup with monitoring and auto-scaling capabilities.

### Step 1: Create Monitoring Stack

Create `docker-compose.monitoring.yml`:

```yaml
version: '3.8'

services:
  # Application
  app:
    build: ./app
    expose:
      - "3000"
    networks:
      - app-network
      - monitoring-network
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "wget", "--quiet", "--tries=1", "--spider", "http://localhost:3000/health"]
      interval: 30s
      timeout: 10s
      retries: 3
    labels:
      - "prometheus.scrape=true"
      - "prometheus.port=3000"

  # Load Balancer
  nginx:
    image: nginx:alpine
    ports:
      - "80:80"
    volumes:
      - ./nginx-lb/nginx.conf:/etc/nginx/conf.d/default.conf
    depends_on:
      - app
    networks:
      - app-network
    restart: unless-stopped

  # Prometheus for metrics collection
  prometheus:
    image: prom/prometheus:latest
    ports:
      - "9090:9090"
    volumes:
      - ./monitoring/prometheus.yml:/etc/prometheus/prometheus.yml
      - prometheus_data:/prometheus
    command:
      - '--config.file=/etc/prometheus/prometheus.yml'
      - '--storage.tsdb.path=/prometheus'
      - '--web.console.libraries=/etc/prometheus/console_libraries'
      - '--web.console.templates=/etc/prometheus/consoles'
      - '--storage.tsdb.retention.time=200h'
      - '--web.enable-lifecycle'
    networks:
      - monitoring-network
    restart: unless-stopped

  # Grafana for visualization
  grafana:
    image: grafana/grafana:latest
    ports:
      - "3001:3000"
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=admin
    volumes:
      - grafana_data:/var/lib/grafana
      - ./monitoring/grafana/dashboards:/etc/grafana/provisioning/dashboards
      - ./monitoring/grafana/datasources:/etc/grafana/provisioning/datasources
    depends_on:
      - prometheus
    networks:
      - monitoring-network
    restart: unless-stopped

  # cAdvisor for container metrics
  cadvisor:
    image: gcr.io/cadvisor/cadvisor:latest
    ports:
      - "8080:8080"
    volumes:
      - /:/rootfs:ro
      - /var/run:/var/run:rw
      - /sys:/sys:ro
      - /var/lib/docker/:/var/lib/docker:ro
    networks:
      - monitoring-network
    restart: unless-stopped

  # Load testing tool
  artillery:
    image: artilleryio/artillery:latest
    volumes:
      - ./load-tests:/scripts
    networks:
      - app-network
    profiles:
      - testing

volumes:
  prometheus_data:
  grafana_data:

networks:
  app-network:
    driver: bridge
  monitoring-network:
    driver: bridge
```

### Step 2: Create Monitoring Configuration

Create `monitoring/prometheus.yml`:

```yaml
global:
  scrape_interval: 15s
  evaluation_interval: 15s

rule_files:
  - "alert_rules.yml"

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']

  - job_name: 'app'
    static_configs:
      - targets: ['app:3000']
    metrics_path: '/metrics'
    scrape_interval: 5s

  - job_name: 'cadvisor'
    static_configs:
      - targets: ['cadvisor:8080']
    scrape_interval: 5s

  - job_name: 'nginx'
    static_configs:
      - targets: ['nginx:80']
    metrics_path: '/lb-status'
    scrape_interval: 10s
```

Create `monitoring/grafana/datasources/prometheus.yml`:

```yaml
apiVersion: 1

datasources:
  - name: Prometheus
    type: prometheus
    access: proxy
    url: http://prometheus:9090
    isDefault: true
```

### Step 3: Create Load Testing Scripts

Create `load-tests/basic-load.yml`:

```yaml
config:
  target: 'http://nginx'
  phases:
    - duration: 60
      arrivalRate: 5
      name: "Warm up"
    - duration: 120
      arrivalRate: 10
      name: "Ramp up load"
    - duration: 300
      arrivalRate: 20
      name: "Sustained load"

scenarios:
  - name: "Basic load test"
    weight: 70
    flow:
      - get:
          url: "/"
      - think: 1

  - name: "Health check"
    weight: 20
    flow:
      - get:
          url: "/health"

  - name: "Work simulation"
    weight: 10
    flow:
      - get:
          url: "/work?duration={{ $randomInt(500, 2000) }}"
      - think: 2
```

### Step 4: Create Auto-Scaling Script

Create `scripts/auto-scale.sh`:

```bash
#!/bin/bash

# Auto-scaling script based on CPU usage
COMPOSE_FILE="docker-compose.monitoring.yml"
SERVICE_NAME="app"
MIN_REPLICAS=1
MAX_REPLICAS=10
SCALE_UP_THRESHOLD=70
SCALE_DOWN_THRESHOLD=30
CHECK_INTERVAL=30

get_cpu_usage() {
    # Get average CPU usage for the service
    docker stats --no-stream --format "table {{.CPUPerc}}" | grep -v CPU | sed 's/%//' | awk '{sum+=$1; count++} END {print sum/count}'
}

get_current_replicas() {
    docker-compose -f $COMPOSE_FILE ps -q $SERVICE_NAME | wc -l
}

scale_service() {
    local new_replicas=$1
    echo "Scaling $SERVICE_NAME to $new_replicas replicas"
    docker-compose -f $COMPOSE_FILE up -d --scale $SERVICE_NAME=$new_replicas
}

while true; do
    cpu_usage=$(get_cpu_usage)
    current_replicas=$(get_current_replicas)
    
    echo "Current CPU usage: ${cpu_usage}%, Current replicas: $current_replicas"
    
    if (( $(echo "$cpu_usage > $SCALE_UP_THRESHOLD" | bc -l) )) && [ $current_replicas -lt $MAX_REPLICAS ]; then
        new_replicas=$((current_replicas + 1))
        echo "High CPU usage detected. Scaling up to $new_replicas replicas"
        scale_service $new_replicas
    elif (( $(echo "$cpu_usage < $SCALE_DOWN_THRESHOLD" | bc -l) )) && [ $current_replicas -gt $MIN_REPLICAS ]; then
        new_replicas=$((current_replicas - 1))
        echo "Low CPU usage detected. Scaling down to $new_replicas replicas"
        scale_service $new_replicas
    fi
    
    sleep $CHECK_INTERVAL
done
```

### Step 5: Test Auto-Scaling

```bash
# Make the script executable
chmod +x scripts/auto-scale.sh

# Start the monitoring stack
docker-compose -f docker-compose.monitoring.yml up -d

# Start auto-scaling in background
./scripts/auto-scale.sh &

# Run load test
docker-compose -f docker-compose.monitoring.yml run --rm artillery run /scripts/basic-load.yml

# Monitor scaling
watch docker-compose -f docker-compose.monitoring.yml ps

# Access monitoring dashboards:
# Prometheus: http://localhost:9090
# Grafana: http://localhost:3001 (admin/admin)
# cAdvisor: http://localhost:8080
```

## Session Management in Scaled Environments

When scaling stateful applications, session management becomes crucial.

### 1. Sticky Sessions (Session Affinity)

Configure nginx for sticky sessions:

```nginx
upstream app_servers {
    ip_hash;  # Route based on client IP
    server app:3000;
}
```

### 2. Shared Session Storage

Use Redis for shared sessions:

```yaml
version: '3.8'

services:
  app:
    build: ./app
    environment:
      - REDIS_URL=redis://redis:6379
      - SESSION_STORE=redis
    depends_on:
      - redis
    networks:
      - app-network

  redis:
    image: redis:alpine
    command: redis-server --appendonly yes
    volumes:
      - redis_data:/data
    networks:
      - app-network

volumes:
  redis_data:
```

### 3. Stateless Application Design

Modify your application to be stateless:

```javascript
// app/server.js - Add session management
const session = require('express-session');
const RedisStore = require('connect-redis')(session);
const redis = require('redis');

const redisClient = redis.createClient({
  url: process.env.REDIS_URL || 'redis://localhost:6379'
});

app.use(session({
  store: new RedisStore({ client: redisClient }),
  secret: process.env.SESSION_SECRET || 'your-secret-key',
  resave: false,
  saveUninitialized: false,
  cookie: { secure: false, maxAge: 3600000 } // 1 hour
}));
```

## Load Balancing Algorithms

### 1. Round Robin (Default)
Requests are distributed evenly across all servers.

```nginx
upstream app_servers {
    server app1:3000;
    server app2:3000;
    server app3:3000;
}
```

### 2. Least Connections
Routes to the server with the fewest active connections.

```nginx
upstream app_servers {
    least_conn;
    server app1:3000;
    server app2:3000;
    server app3:3000;
}
```

### 3. IP Hash
Routes based on client IP hash (sticky sessions).

```nginx
upstream app_servers {
    ip_hash;
    server app1:3000;
    server app2:3000;
    server app3:3000;
}
```

### 4. Weighted Round Robin
Distributes load based on server weights.

```nginx
upstream app_servers {
    server app1:3000 weight=3;
    server app2:3000 weight=2;
    server app3:3000 weight=1;
}
```

## Health Checks and Circuit Breakers

### Application Health Checks

```javascript
// Enhanced health check endpoint
app.get('/health', async (req, res) => {
  const health = {
    status: 'healthy',
    timestamp: new Date().toISOString(),
    instance: instanceId,
    uptime: process.uptime(),
    memory: process.memoryUsage(),
    checks: {}
  };

  try {
    // Database check
    if (process.env.DATABASE_URL) {
      // Perform database ping
      health.checks.database = 'healthy';
    }

    // Redis check
    if (process.env.REDIS_URL) {
      // Perform Redis ping
      health.checks.redis = 'healthy';
    }

    res.json(health);
  } catch (error) {
    health.status = 'unhealthy';
    health.error = error.message;
    res.status(503).json(health);
  }
});
```

### Load Balancer Health Checks

```nginx
upstream app_servers {
    server app:3000 max_fails=3 fail_timeout=30s;
}

server {
    location / {
        proxy_pass http://app_servers;
        proxy_next_upstream error timeout invalid_header http_500 http_502 http_503 http_504;
        proxy_connect_timeout 5s;
        proxy_send_timeout 10s;
        proxy_read_timeout 10s;
    }
}
```

## Performance Monitoring and Metrics

### Key Metrics to Monitor

1. **Response Time**: Average, 95th percentile, 99th percentile
2. **Throughput**: Requests per second
3. **Error Rate**: Percentage of failed requests
4. **Resource Usage**: CPU, memory, disk I/O
5. **Queue Depth**: Number of pending requests

### Monitoring with Prometheus

Add metrics to your application:

```javascript
const promClient = require('prom-client');

// Create metrics
const httpRequestDuration = new promClient.Histogram({
  name: 'http_request_duration_seconds',
  help: 'Duration of HTTP requests in seconds',
  labelNames: ['method', 'route', 'status_code'],
  buckets: [0.1, 0.3, 0.5, 0.7, 1, 3, 5, 7, 10]
});

const httpRequestsTotal = new promClient.Counter({
  name: 'http_requests_total',
  help: 'Total number of HTTP requests',
  labelNames: ['method', 'route', 'status_code']
});

// Middleware to collect metrics
app.use((req, res, next) => {
  const start = Date.now();
  
  res.on('finish', () => {
    const duration = (Date.now() - start) / 1000;
    const labels = {
      method: req.method,
      route: req.route?.path || req.path,
      status_code: res.statusCode
    };
    
    httpRequestDuration.observe(labels, duration);
    httpRequestsTotal.inc(labels);
  });
  
  next();
});

// Metrics endpoint
app.get('/metrics', (req, res) => {
  res.set('Content-Type', promClient.register.contentType);
  res.end(promClient.register.metrics());
});
```

## Best Practices for Scaling

### 1. Design for Horizontal Scaling
- Make applications stateless
- Use external storage for sessions and data
- Implement proper health checks
- Handle graceful shutdowns

### 2. Resource Management
```yaml
services:
  app:
    deploy:
      resources:
        limits:
          cpus: '0.5'
          memory: 512M
        reservations:
          cpus: '0.25'
          memory: 256M
```

### 3. Gradual Scaling
- Scale incrementally (add/remove one instance at a time)
- Monitor performance after each scaling operation
- Implement proper cooldown periods

### 4. Load Testing
- Test your application under various load conditions
- Identify bottlenecks before production
- Validate auto-scaling behavior

## Summary

In this lesson, you learned:
- How to scale services horizontally with Docker Compose
- Load balancing strategies and configurations
- Health checks and monitoring for scaled applications
- Session management in distributed environments
- Auto-scaling patterns and best practices
- Performance monitoring and metrics collection

## Next Steps
- Practice scaling different types of applications
- Experiment with various load balancing algorithms
- Set up comprehensive monitoring for your scaled services
- Move on to Lesson 4: Multi-Environment Deployments

## Additional Resources
- [Load Balancing Algorithms](https://nginx.org/en/docs/http/load_balancing.html)
- [HAProxy Configuration Guide](https://www.haproxy.org/download/2.4/doc/configuration.txt)
- [Prometheus Monitoring](https://prometheus.io/docs/guides/go-application/)
- [Container Performance Tuning](https://docs.docker.com/config/containers/resource_constraints/)
