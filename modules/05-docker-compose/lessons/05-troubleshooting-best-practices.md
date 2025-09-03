# Lesson 5: Troubleshooting and Best Practices

## Learning Objectives
By the end of this lesson, you will be able to:
- Diagnose and resolve common Docker Compose issues
- Implement monitoring and logging best practices
- Optimize Docker Compose performance
- Apply security best practices for production deployments
- Use debugging tools and techniques effectively
- Implement proper backup and recovery strategies

## Prerequisites
- Completed all previous Docker Compose lessons
- Understanding of Docker fundamentals
- Basic knowledge of system administration and debugging

## Common Docker Compose Issues

### 1. Service Startup Problems

**Symptoms:**
- Services fail to start
- Containers exit immediately
- Dependency issues

**Common Causes and Solutions:**

```bash
# Check service status
docker-compose ps

# View service logs
docker-compose logs service-name

# Check for configuration errors
docker-compose config

# Validate YAML syntax
docker-compose config --quiet
```

### 2. Network Connectivity Issues

**Symptoms:**
- Services cannot communicate
- DNS resolution failures
- Port binding conflicts

**Debugging Steps:**

```bash
# Test connectivity between services
docker-compose exec service1 ping service2

# Check DNS resolution
docker-compose exec service1 nslookup service2

# Inspect networks
docker network ls
docker network inspect network-name

# Check port bindings
docker-compose port service-name port-number
```

### 3. Volume and Storage Issues

**Symptoms:**
- Data not persisting
- Permission denied errors
- Volume mount failures

**Troubleshooting:**

```bash
# Check volume mounts
docker-compose exec service ls -la /mounted/path

# Inspect volumes
docker volume ls
docker volume inspect volume-name

# Check permissions
docker-compose exec service id
docker-compose exec service ls -la /path
```

## Hands-on Lab 1: Comprehensive Debugging Setup

Let's create a debugging environment with common issues and learn to resolve them.

### Step 1: Create Problematic Application

Create `debug-app/docker-compose.yml`:

```yaml
version: '3.8'

services:
  # Web service with configuration issues
  web:
    image: nginx:alpine
    ports:
      - "8080:80"
    volumes:
      - ./html:/usr/share/nginx/html
      - ./nginx.conf:/etc/nginx/conf.d/default.conf
    depends_on:
      - api
    networks:
      - frontend
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost/health"]
      interval: 30s
      timeout: 10s
      retries: 3

  # API service with dependency issues
  api:
    build: ./api
    ports:
      - "3000:3000"
    environment:
      - NODE_ENV=development
      - DATABASE_URL=postgresql://user:pass@database:5432/myapp
      - REDIS_URL=redis://cache:6379
    depends_on:
      database:
        condition: service_healthy
      cache:
        condition: service_started
    networks:
      - frontend
      - backend
    volumes:
      - ./api:/app
      - /app/node_modules
    restart: unless-stopped

  # Database with initialization issues
  database:
    image: postgres:13
    environment:
      POSTGRES_DB: myapp
      POSTGRES_USER: user
      POSTGRES_PASSWORD: pass
    volumes:
      - db_data:/var/lib/postgresql/data
      - ./init.sql:/docker-entrypoint-initdb.d/init.sql
    networks:
      - backend
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U user"]
      interval: 30s
      timeout: 10s
      retries: 5
    ports:
      - "5432:5432"

  # Cache service
  cache:
    image: redis:alpine
    command: redis-server --appendonly yes
    volumes:
      - cache_data:/data
    networks:
      - backend
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 30s
      timeout: 10s
      retries: 3

  # Monitoring service
  monitor:
    image: prom/prometheus:latest
    ports:
      - "9090:9090"
    volumes:
      - ./prometheus.yml:/etc/prometheus/prometheus.yml
      - prometheus_data:/prometheus
    networks:
      - monitoring
    command:
      - '--config.file=/etc/prometheus/prometheus.yml'
      - '--storage.tsdb.path=/prometheus'
      - '--web.console.libraries=/etc/prometheus/console_libraries'
      - '--web.console.templates=/etc/prometheus/consoles'

volumes:
  db_data:
  cache_data:
  prometheus_data:

networks:
  frontend:
    driver: bridge
  backend:
    driver: bridge
  monitoring:
    driver: bridge
```

### Step 2: Create Application Files with Issues

Create `debug-app/api/Dockerfile`:

```dockerfile
FROM node:16-alpine

WORKDIR /app

# Install dependencies
COPY package*.json ./
RUN npm install

# Copy source code
COPY . .

# Intentional issue: wrong port exposure
EXPOSE 4000

# Create non-root user
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nodejs -u 1001

# Intentional issue: missing user switch
# USER nodejs

CMD ["npm", "start"]
```

Create `debug-app/api/package.json`:

```json
{
  "name": "debug-api",
  "version": "1.0.0",
  "main": "server.js",
  "scripts": {
    "start": "node server.js",
    "dev": "nodemon server.js"
  },
  "dependencies": {
    "express": "^4.18.0",
    "pg": "^8.8.0",
    "redis": "^4.3.0"
  },
  "devDependencies": {
    "nodemon": "^2.0.20"
  }
}
```

Create `debug-app/api/server.js`:

```javascript
const express = require('express');
const { Client } = require('pg');
const redis = require('redis');

const app = express();
const port = process.env.PORT || 3000;

// Intentional issue: incorrect Redis connection
const redisClient = redis.createClient({
  url: process.env.REDIS_URL || 'redis://wrong-host:6379'
});

// Intentional issue: missing error handling
const pgClient = new Client({
  connectionString: process.env.DATABASE_URL
});

app.use(express.json());

// Health check endpoint
app.get('/health', async (req, res) => {
  try {
    // Test database connection
    await pgClient.query('SELECT 1');
    
    // Test Redis connection
    await redisClient.ping();
    
    res.json({ status: 'healthy' });
  } catch (error) {
    res.status(503).json({ 
      status: 'unhealthy', 
      error: error.message 
    });
  }
});

app.get('/api/data', async (req, res) => {
  try {
    const result = await pgClient.query('SELECT NOW() as timestamp');
    res.json(result.rows[0]);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Intentional issue: missing connection initialization
app.listen(port, () => {
  console.log(`Server running on port ${port}`);
});

// Add connection initialization (fix)
async function initializeConnections() {
  try {
    await pgClient.connect();
    await redisClient.connect();
    console.log('Database and cache connections established');
  } catch (error) {
    console.error('Connection error:', error);
    process.exit(1);
  }
}

// Uncomment to fix connection issues
// initializeConnections();
```

Create `debug-app/nginx.conf`:

```nginx
upstream api_backend {
    # Intentional issue: wrong port
    server api:4000;
}

server {
    listen 80;
    server_name localhost;
    
    location / {
        root /usr/share/nginx/html;
        index index.html;
    }
    
    location /api/ {
        proxy_pass http://api_backend/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        
        # Intentional issue: very short timeout
        proxy_connect_timeout 1s;
        proxy_send_timeout 1s;
        proxy_read_timeout 1s;
    }
    
    # Missing health endpoint
}
```

Create `debug-app/html/index.html`:

```html
<!DOCTYPE html>
<html>
<head>
    <title>Debug Application</title>
</head>
<body>
    <h1>Debug Application</h1>
    <div id="status">Loading...</div>
    <div id="data">Loading...</div>
    
    <script>
        // Test health endpoint
        fetch('/api/health')
            .then(response => response.json())
            .then(data => {
                document.getElementById('status').innerHTML = 
                    'Health: ' + JSON.stringify(data);
            })
            .catch(error => {
                document.getElementById('status').innerHTML = 
                    'Health Error: ' + error.message;
            });
            
        // Test data endpoint
        fetch('/api/data')
            .then(response => response.json())
            .then(data => {
                document.getElementById('data').innerHTML = 
                    'Data: ' + JSON.stringify(data);
            })
            .catch(error => {
                document.getElementById('data').innerHTML = 
                    'Data Error: ' + error.message;
            });
    </script>
</body>
</html>
```

### Step 3: Create Debugging Scripts

Create `debug-app/scripts/debug.sh`:

```bash
#!/bin/bash

echo "=== Docker Compose Debugging Script ==="

# Check if docker-compose.yml exists
if [ ! -f "docker-compose.yml" ]; then
    echo "❌ docker-compose.yml not found!"
    exit 1
fi

echo "✅ docker-compose.yml found"

# Validate YAML syntax
echo "🔍 Validating YAML syntax..."
if docker-compose config --quiet; then
    echo "✅ YAML syntax is valid"
else
    echo "❌ YAML syntax errors found"
    docker-compose config
    exit 1
fi

# Check service status
echo "🔍 Checking service status..."
docker-compose ps

# Check for failed services
FAILED_SERVICES=$(docker-compose ps --services --filter "status=exited")
if [ -n "$FAILED_SERVICES" ]; then
    echo "❌ Failed services detected: $FAILED_SERVICES"
    
    for service in $FAILED_SERVICES; do
        echo "📋 Logs for $service:"
        docker-compose logs --tail=20 $service
        echo "---"
    done
else
    echo "✅ All services are running"
fi

# Check network connectivity
echo "🔍 Testing network connectivity..."
if docker-compose exec -T web ping -c 1 api >/dev/null 2>&1; then
    echo "✅ Web can reach API"
else
    echo "❌ Web cannot reach API"
fi

if docker-compose exec -T api ping -c 1 database >/dev/null 2>&1; then
    echo "✅ API can reach Database"
else
    echo "❌ API cannot reach Database"
fi

# Check health endpoints
echo "🔍 Testing health endpoints..."
WEB_PORT=$(docker-compose port web 80 2>/dev/null | cut -d: -f2)
if [ -n "$WEB_PORT" ]; then
    if curl -f "http://localhost:$WEB_PORT/api/health" >/dev/null 2>&1; then
        echo "✅ API health check passed"
    else
        echo "❌ API health check failed"
    fi
fi

# Check resource usage
echo "🔍 Checking resource usage..."
docker stats --no-stream --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}"

echo "=== Debug complete ==="
```

Create `debug-app/scripts/fix-issues.sh`:

```bash
#!/bin/bash

echo "=== Fixing Common Issues ==="

# Fix 1: Correct nginx upstream port
echo "🔧 Fixing nginx upstream port..."
sed -i 's/server api:4000;/server api:3000;/' nginx.conf

# Fix 2: Add health endpoint to nginx
echo "🔧 Adding health endpoint to nginx..."
cat >> nginx.conf << 'EOF'
    
    location /health {
        access_log off;
        return 200 "nginx healthy\n";
        add_header Content-Type text/plain;
    }
EOF

# Fix 3: Fix API Dockerfile port
echo "🔧 Fixing API Dockerfile port..."
sed -i 's/EXPOSE 4000/EXPOSE 3000/' api/Dockerfile

# Fix 4: Add user switch in Dockerfile
echo "🔧 Adding user switch in Dockerfile..."
sed -i '/# USER nodejs/s/# //' api/Dockerfile

# Fix 5: Fix Redis connection in server.js
echo "🔧 Fixing Redis connection..."
sed -i 's/redis:\/\/wrong-host:6379/redis:\/\/cache:6379/' api/server.js

# Fix 6: Uncomment connection initialization
echo "🔧 Enabling connection initialization..."
sed -i 's/\/\/ initializeConnections();/initializeConnections();/' api/server.js

# Fix 7: Increase nginx timeouts
echo "🔧 Increasing nginx timeouts..."
sed -i 's/proxy_connect_timeout 1s;/proxy_connect_timeout 30s;/' nginx.conf
sed -i 's/proxy_send_timeout 1s;/proxy_send_timeout 30s;/' nginx.conf
sed -i 's/proxy_read_timeout 1s;/proxy_read_timeout 30s;/' nginx.conf

echo "✅ Issues fixed! Rebuild and restart services:"
echo "   docker-compose down"
echo "   docker-compose build"
echo "   docker-compose up -d"
```

### Step 4: Test Debugging Process

```bash
cd debug-app

# Make scripts executable
chmod +x scripts/*.sh

# Start the problematic application
docker-compose up -d

# Run debugging script
./scripts/debug.sh

# Fix the issues
./scripts/fix-issues.sh

# Rebuild and restart
docker-compose down
docker-compose build
docker-compose up -d

# Test again
./scripts/debug.sh
```

## Performance Optimization

### 1. Image Optimization

```dockerfile
# Multi-stage build for smaller images
FROM node:16-alpine as builder
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production

FROM node:16-alpine as runtime
WORKDIR /app
COPY --from=builder /app/node_modules ./node_modules
COPY . .
USER node
CMD ["node", "server.js"]
```

### 2. Resource Limits

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
    restart: unless-stopped
```

### 3. Health Checks

```yaml
services:
  app:
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:3000/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s
```

### 4. Logging Configuration

```yaml
services:
  app:
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"
        labels: "service=app,environment=production"
```

## Monitoring and Observability

### Hands-on Lab 2: Comprehensive Monitoring Setup

Create `monitoring/docker-compose.monitoring.yml`:

```yaml
version: '3.8'

services:
  # Application services
  app:
    build: ./app
    ports:
      - "3000:3000"
    environment:
      - NODE_ENV=production
    networks:
      - app-network
      - monitoring-network
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:3000/health"]
      interval: 30s
      timeout: 10s
      retries: 3
    labels:
      - "prometheus.scrape=true"
      - "prometheus.port=3000"
      - "prometheus.path=/metrics"

  # Prometheus for metrics collection
  prometheus:
    image: prom/prometheus:latest
    ports:
      - "9090:9090"
    volumes:
      - ./prometheus/prometheus.yml:/etc/prometheus/prometheus.yml
      - ./prometheus/rules:/etc/prometheus/rules
      - prometheus_data:/prometheus
    command:
      - '--config.file=/etc/prometheus/prometheus.yml'
      - '--storage.tsdb.path=/prometheus'
      - '--web.console.libraries=/etc/prometheus/console_libraries'
      - '--web.console.templates=/etc/prometheus/consoles'
      - '--storage.tsdb.retention.time=200h'
      - '--web.enable-lifecycle'
      - '--web.enable-admin-api'
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
      - GF_USERS_ALLOW_SIGN_UP=false
    volumes:
      - grafana_data:/var/lib/grafana
      - ./grafana/dashboards:/etc/grafana/provisioning/dashboards
      - ./grafana/datasources:/etc/grafana/provisioning/datasources
    networks:
      - monitoring-network
    restart: unless-stopped
    depends_on:
      - prometheus

  # AlertManager for alerting
  alertmanager:
    image: prom/alertmanager:latest
    ports:
      - "9093:9093"
    volumes:
      - ./alertmanager/alertmanager.yml:/etc/alertmanager/alertmanager.yml
      - alertmanager_data:/alertmanager
    command:
      - '--config.file=/etc/alertmanager/alertmanager.yml'
      - '--storage.path=/alertmanager'
      - '--web.external-url=http://localhost:9093'
    networks:
      - monitoring-network
    restart: unless-stopped

  # Node Exporter for system metrics
  node-exporter:
    image: prom/node-exporter:latest
    ports:
      - "9100:9100"
    volumes:
      - /proc:/host/proc:ro
      - /sys:/host/sys:ro
      - /:/rootfs:ro
    command:
      - '--path.procfs=/host/proc'
      - '--path.sysfs=/host/sys'
      - '--collector.filesystem.ignored-mount-points=^/(sys|proc|dev|host|etc)($$|/)'
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

  # Loki for log aggregation
  loki:
    image: grafana/loki:latest
    ports:
      - "3100:3100"
    volumes:
      - ./loki/loki.yml:/etc/loki/local-config.yaml
      - loki_data:/loki
    command: -config.file=/etc/loki/local-config.yaml
    networks:
      - monitoring-network
    restart: unless-stopped

  # Promtail for log collection
  promtail:
    image: grafana/promtail:latest
    volumes:
      - ./promtail/promtail.yml:/etc/promtail/config.yml
      - /var/log:/var/log:ro
      - /var/lib/docker/containers:/var/lib/docker/containers:ro
    command: -config.file=/etc/promtail/config.yml
    networks:
      - monitoring-network
    restart: unless-stopped
    depends_on:
      - loki

  # Jaeger for distributed tracing
  jaeger:
    image: jaegertracing/all-in-one:latest
    ports:
      - "16686:16686"
      - "14268:14268"
    environment:
      - COLLECTOR_ZIPKIN_HTTP_PORT=9411
    networks:
      - monitoring-network
    restart: unless-stopped

volumes:
  prometheus_data:
  grafana_data:
  alertmanager_data:
  loki_data:

networks:
  app-network:
    driver: bridge
  monitoring-network:
    driver: bridge
```

### Monitoring Configuration Files

Create `monitoring/prometheus/prometheus.yml`:

```yaml
global:
  scrape_interval: 15s
  evaluation_interval: 15s

rule_files:
  - "/etc/prometheus/rules/*.yml"

alerting:
  alertmanagers:
    - static_configs:
        - targets:
          - alertmanager:9093

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']

  - job_name: 'app'
    static_configs:
      - targets: ['app:3000']
    metrics_path: '/metrics'
    scrape_interval: 5s

  - job_name: 'node-exporter'
    static_configs:
      - targets: ['node-exporter:9100']

  - job_name: 'cadvisor'
    static_configs:
      - targets: ['cadvisor:8080']

  - job_name: 'docker-containers'
    docker_sd_configs:
      - host: unix:///var/run/docker.sock
        refresh_interval: 5s
    relabel_configs:
      - source_labels: [__meta_docker_container_label_prometheus_scrape]
        action: keep
        regex: true
      - source_labels: [__meta_docker_container_label_prometheus_port]
        action: replace
        regex: (.+)
        target_label: __address__
        replacement: ${1}
      - source_labels: [__meta_docker_container_label_prometheus_path]
        action: replace
        target_label: __metrics_path__
        regex: (.+)
```

Create `monitoring/prometheus/rules/alerts.yml`:

```yaml
groups:
  - name: application_alerts
    rules:
      - alert: HighErrorRate
        expr: rate(http_requests_total{status=~"5.."}[5m]) > 0.1
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "High error rate detected"
          description: "Error rate is {{ $value }} errors per second"

      - alert: HighMemoryUsage
        expr: (container_memory_usage_bytes / container_spec_memory_limit_bytes) > 0.8
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "High memory usage"
          description: "Memory usage is above 80%"

      - alert: ServiceDown
        expr: up == 0
        for: 1m
        labels:
          severity: critical
        annotations:
          summary: "Service is down"
          description: "{{ $labels.instance }} is down"

      - alert: HighCPUUsage
        expr: rate(container_cpu_usage_seconds_total[5m]) > 0.8
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "High CPU usage"
          description: "CPU usage is above 80%"
```

## Security Best Practices

### 1. Container Security

```dockerfile
# Use specific versions, not latest
FROM node:16.20.0-alpine

# Create non-root user
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nodejs -u 1001

# Set working directory
WORKDIR /app

# Copy and install dependencies as root
COPY package*.json ./
RUN npm ci --only=production && \
    npm cache clean --force

# Copy application code
COPY . .

# Change ownership to non-root user
RUN chown -R nodejs:nodejs /app

# Switch to non-root user
USER nodejs

# Use specific port
EXPOSE 3000

# Use exec form for CMD
CMD ["node", "server.js"]
```

### 2. Secrets Management

```yaml
version: '3.8'

services:
  app:
    image: myapp:latest
    environment:
      - DB_HOST=database
      - DB_USER=appuser
      - DB_PASSWORD_FILE=/run/secrets/db_password
    secrets:
      - db_password
    networks:
      - app-network

  database:
    image: postgres:13
    environment:
      - POSTGRES_USER=appuser
      - POSTGRES_PASSWORD_FILE=/run/secrets/db_password
      - POSTGRES_DB=myapp
    secrets:
      - db_password
    volumes:
      - db_data:/var/lib/postgresql/data
    networks:
      - app-network

secrets:
  db_password:
    file: ./secrets/db_password.txt

volumes:
  db_data:

networks:
  app-network:
    driver: bridge
```

### 3. Network Security

```yaml
version: '3.8'

services:
  web:
    image: nginx:alpine
    ports:
      - "80:80"
      - "443:443"
    networks:
      - frontend
    # Only expose necessary ports

  api:
    build: ./api
    expose:
      - "3000"  # Use expose instead of ports for internal services
    networks:
      - frontend
      - backend

  database:
    image: postgres:13
    # No ports exposed to host
    networks:
      - backend  # Only accessible from backend network

networks:
  frontend:
    driver: bridge
  backend:
    driver: bridge
    internal: true  # No external access
```

### 4. Resource Limits and Security

```yaml
services:
  app:
    build: ./app
    deploy:
      resources:
        limits:
          cpus: '0.5'
          memory: 512M
        reservations:
          cpus: '0.25'
          memory: 256M
    security_opt:
      - no-new-privileges:true
    read_only: true
    tmpfs:
      - /tmp
      - /var/cache
    cap_drop:
      - ALL
    cap_add:
      - NET_BIND_SERVICE
```

## Backup and Recovery

### Hands-on Lab 3: Backup and Recovery Strategy

Create `backup/docker-compose.backup.yml`:

```yaml
version: '3.8'

services:
  app:
    build: ./app
    depends_on:
      - database
      - redis
    networks:
      - app-network

  database:
    image: postgres:13
    environment:
      POSTGRES_DB: myapp
      POSTGRES_USER: user
      POSTGRES_PASSWORD: pass
    volumes:
      - db_data:/var/lib/postgresql/data
    networks:
      - app-network

  redis:
    image: redis:alpine
    command: redis-server --appendonly yes
    volumes:
      - redis_data:/data
    networks:
      - app-network

  # Backup service
  backup:
    image: postgres:13
    volumes:
      - db_data:/var/lib/postgresql/data:ro
      - redis_data:/redis-data:ro
      - ./backups:/backups
      - ./scripts:/scripts
    environment:
      PGPASSWORD: pass
    networks:
      - app-network
    profiles:
      - backup

volumes:
  db_data:
  redis_data:

networks:
  app-network:
```

Create `backup/scripts/backup.sh`:

```bash
#!/bin/bash
set -e

BACKUP_DIR="/backups"
DATE=$(date +%Y%m%d_%H%M%S)

echo "Starting backup at $(date)"

# Create backup directory
mkdir -p "$BACKUP_DIR/$DATE"

# Backup PostgreSQL
echo "Backing up PostgreSQL..."
pg_dump -h database -U user -d myapp > "$BACKUP_DIR/$DATE/postgres_backup.sql"

# Backup Redis
echo "Backing up Redis..."
cp /redis-data/appendonly.aof "$BACKUP_DIR/$DATE/redis_backup.aof" 2>/dev/null || echo "Redis AOF not found"

# Backup application data (if any)
echo "Backing up application data..."
tar -czf "$BACKUP_DIR/$DATE/app_data.tar.gz" -C /var/lib/postgresql/data . 2>/dev/null || true

# Create backup manifest
cat > "$BACKUP_DIR/$DATE/manifest.txt" << EOF
Backup created: $(date)
PostgreSQL: postgres_backup.sql
Redis: redis_backup.aof
Application Data: app_data.tar.gz
EOF

# Compress backup
echo "Compressing backup..."
tar -czf "$BACKUP_DIR/backup_$DATE.tar.gz" -C "$BACKUP_DIR" "$DATE"
rm -rf "$BACKUP_DIR/$DATE"

# Cleanup old backups (keep last 7 days)
find "$BACKUP_DIR" -name "backup_*.tar.gz" -mtime +7 -delete

echo "Backup completed: backup_$DATE.tar.gz"
```

Create `backup/scripts/restore.sh`:

```bash
#!/bin/bash
set -e

BACKUP_FILE=$1
BACKUP_DIR="/backups"

if [ -z "$BACKUP_FILE" ]; then
    echo "Usage: $0 <backup_file>"
    echo "Available backups:"
    ls -la "$BACKUP_DIR"/backup_*.tar.gz
    exit 1
fi

if [ ! -f "$BACKUP_DIR/$BACKUP_FILE" ]; then
    echo "Backup file not found: $BACKUP_DIR/$BACKUP_FILE"
    exit 1
fi

echo "Starting restore from $BACKUP_FILE at $(date)"

# Extract backup
TEMP_DIR="/tmp/restore_$$"
mkdir -p "$TEMP_DIR"
tar -xzf "$BACKUP_DIR/$BACKUP_FILE" -C "$TEMP_DIR"

RESTORE_DIR=$(find "$TEMP_DIR" -maxdepth 1 -type d -name "20*" | head -1)

if [ -z "$RESTORE_DIR" ]; then
    echo "Invalid backup file structure"
    rm -rf "$TEMP_DIR"
    exit 1
fi

# Restore PostgreSQL
if [ -f "$RESTORE_DIR/postgres_backup.sql" ]; then
    echo "Restoring PostgreSQL..."
    psql -h database -U user -d myapp < "$RESTORE_DIR/postgres_backup.sql"
else
    echo "PostgreSQL backup not found"
fi

# Restore Redis
if [ -f "$RESTORE_DIR/redis_backup.aof" ]; then
    echo "Restoring Redis..."
    # Note: This requires stopping Redis first
    echo "Manual step required: Stop Redis, copy AOF file, restart Redis"
else
    echo "Redis backup not found"
fi

# Cleanup
rm -rf "$TEMP_DIR"

echo "Restore completed at $(date)"
```

### Automated Backup with Cron

Create `backup/scripts/schedule-backup.sh`:

```bash
#!/bin/bash

# Add backup job to crontab
# Run backup every day at 2 AM
(crontab -l 2>/dev/null; echo "0 2 * * * cd /path/to/backup && docker-compose --profile backup run --rm backup /scripts/backup.sh") | crontab -

echo "Backup scheduled for 2 AM daily"
```

## Production Deployment Checklist

### Pre-Deployment Checklist

```bash
# 1. Security Review
- [ ] All secrets properly managed
- [ ] No hardcoded passwords
- [ ] Non-root users in containers
- [ ] Network segmentation implemented
- [ ] Resource limits configured

# 2. Performance Review
- [ ] Health checks configured
- [ ] Logging properly configured
- [ ] Monitoring setup complete
- [ ] Resource limits appropriate
- [ ] Image sizes optimized

# 3. Reliability Review
- [ ] Restart policies configured
- [ ] Backup strategy implemented
- [ ] Recovery procedures tested
- [ ] Dependencies properly handled
- [ ] Graceful shutdown implemented
```

### Production Configuration Template

Create `production/docker-compose.prod.yml`:

```yaml
version: '3.8'

services:
  web:
    image: myapp/web:${VERSION}
    deploy:
      replicas: 3
      resources:
        limits:
          cpus: '1'
          memory: 512M
        reservations:
          cpus: '0.5'
          memory: 256M
      restart_policy:
        condition: on-failure
        delay: 5s
        max_attempts: 3
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./ssl:/etc/ssl:ro
    networks:
      - frontend
    healthcheck:
      test: ["CMD", "curl", "-f", "https://localhost/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"
        labels: "service=web,environment=production"

  api:
    image: myapp/api:${VERSION}
    deploy:
      replicas: 3
      resources:
        limits:
          cpus: '1'
          memory: 1G
        reservations:
          cpus: '0.5'
          memory: 512M
      restart_policy:
        condition: on-failure
        delay: 5s
        max_attempts: 3
    expose:
      - "3000"
    environment:
      - NODE_ENV=production
      - DB_HOST=database
      - DB_PASSWORD_FILE=/run/secrets/db_password
    secrets:
      - db_password
    networks:
      - frontend
      - backend
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:3000/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"
        labels: "service=api,environment=production"

  database:
    image: postgres:13
    deploy:
      resources:
        limits:
          cpus: '2'
          memory: 2G
        reservations:
          cpus: '1'
          memory: 1G
    environment:
      - POSTGRES_DB=myapp
      - POSTGRES_USER=appuser
      - POSTGRES_PASSWORD_FILE=/run/secrets/db_password
    secrets:
      - db_password
    volumes:
      - db_data:/var/lib/postgresql/data
    networks:
      - backend
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U appuser"]
      interval: 30s
      timeout: 10s
      retries: 5
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"
        labels: "service=database,environment=production"

secrets:
  db_password:
    external: true

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

## Advanced Debugging Techniques

### 1. Container Debugging

```bash
# Enter a running container
docker-compose exec service-name sh

# Run a command in a new container instance
docker-compose run --rm service-name sh

# Debug a failed container
docker-compose run --rm --entrypoint sh service-name

# Check container processes
docker-compose exec service-name ps aux

# Monitor container resources
docker-compose exec service-name top
```

### 2. Network Debugging

```bash
# Test connectivity
docker-compose exec service1 ping service2
docker-compose exec service1 telnet service2 port
docker-compose exec service1 nc -zv service2 port

# Check DNS resolution
docker-compose exec service1 nslookup service2
docker-compose exec service1 dig service2

# Inspect network configuration
docker network inspect $(docker-compose ps -q | head -1 | xargs docker inspect --format='{{range .NetworkSettings.Networks}}{{.NetworkID}}{{end}}')
```

### 3. Volume Debugging

```bash
# Check volume contents
docker-compose exec service ls -la /mounted/path

# Check volume permissions
docker-compose exec service stat /mounted/path

# Compare host and container permissions
ls -la ./host/path
docker-compose exec service ls -la /container/path
```

### 4. Log Analysis

```bash
# View logs with timestamps
docker-compose logs -t service-name

# Follow logs in real-time
docker-compose logs -f service-name

# Search logs for errors
docker-compose logs service-name | grep -i error

# Export logs for analysis
docker-compose logs service-name > service-logs.txt
```

## Best Practices Summary

### 1. Development Best Practices

- **Use .dockerignore** to exclude unnecessary files
- **Pin image versions** for reproducible builds
- **Use multi-stage builds** to reduce image size
- **Implement proper health checks**
- **Use non-root users** in containers

### 2. Configuration Best Practices

- **Use environment variables** for configuration
- **Keep secrets separate** from configuration
- **Validate configurations** before deployment
- **Use override files** for environment-specific settings
- **Document configuration options**

### 3. Security Best Practices

- **Never commit secrets** to version control
- **Use secrets management** for sensitive data
- **Implement network segmentation**
- **Apply resource limits**
- **Regular security updates**

### 4. Monitoring Best Practices

- **Implement comprehensive logging**
- **Set up health checks**
- **Monitor resource usage**
- **Configure alerting**
- **Regular backup testing**

### 5. Deployment Best Practices

- **Use CI/CD pipelines**
- **Implement blue-green deployments**
- **Test in staging environments**
- **Have rollback procedures**
- **Monitor post-deployment**

## Troubleshooting Quick Reference

### Common Commands

```bash
# Service management
docker-compose ps                    # List services
docker-compose logs service-name     # View logs
docker-compose restart service-name  # Restart service
docker-compose exec service-name sh  # Enter container

# Configuration
docker-compose config               # Validate and view config
docker-compose config --quiet       # Validate syntax only
docker-compose version             # Show version info

# Cleanup
docker-compose down                 # Stop and remove containers
docker-compose down -v              # Also remove volumes
docker-compose down --rmi all       # Also remove images
docker system prune                 # Clean up unused resources
```

### Emergency Procedures

```bash
# Quick health check
docker-compose ps
docker stats --no-stream

# Emergency restart
docker-compose restart

# Emergency stop
docker-compose down

# Force cleanup
docker-compose down -v --remove-orphans
docker system prune -f
```

## Summary

In this lesson, you learned:
- How to diagnose and resolve common Docker Compose issues
- Performance optimization techniques
- Security best practices for production deployments
- Comprehensive monitoring and observability setup
- Backup and recovery strategies
- Advanced debugging techniques
- Production deployment best practices

## Next Steps
- Practice troubleshooting with the provided examples
- Set up monitoring for your applications
- Implement security best practices
- Create backup and recovery procedures
- Move on to Module 6: Production Ready

## Additional Resources
- [Docker Compose Troubleshooting](https://docs.docker.com/compose/troubleshooting/)
- [Container Security Best Practices](https://docs.docker.com/engine/security/)
- [Docker Production Best Practices](https://docs.docker.com/develop/dev-best-practices/)
- [Prometheus Monitoring Guide](https://prometheus.io/docs/guides/)
- [Docker Logging Best Practices](https://docs.docker.com/config/containers/logging/)
