# Lesson 4: Multi-Environment Deployments

## Learning Objectives
By the end of this lesson, you will be able to:
- Configure applications for multiple environments (dev, staging, production)
- Use Docker Compose override files and profiles
- Manage environment-specific configurations and secrets
- Implement configuration templating and variable substitution
- Deploy the same application stack across different environments
- Handle environment-specific networking and storage requirements

## Prerequisites
- Completed previous Docker Compose lessons
- Understanding of software deployment lifecycle
- Basic knowledge of environment configuration management

## Introduction to Multi-Environment Deployments

Modern applications typically go through multiple environments before reaching production:

### Environment Types

1. **Development**: Local development with debugging tools
2. **Testing**: Automated testing environment
3. **Staging**: Production-like environment for final testing
4. **Production**: Live environment serving real users

### Key Challenges

- **Configuration Management**: Different settings per environment
- **Resource Requirements**: Varying CPU, memory, and storage needs
- **Security**: Different levels of access and secrets management
- **Networking**: Environment-specific domains and ports
- **Data**: Different databases and data volumes

## Docker Compose Override Files

Docker Compose supports multiple files to handle environment-specific configurations.

### File Precedence

```bash
# Default behavior - automatically loads both files
docker-compose up
# Loads: docker-compose.yml + docker-compose.override.yml

# Explicit file specification
docker-compose -f docker-compose.yml -f docker-compose.prod.yml up

# Multiple override files
docker-compose -f docker-compose.yml -f docker-compose.staging.yml -f docker-compose.monitoring.yml up
```

### Base Configuration

Create `docker-compose.yml` (base configuration):

```yaml
version: '3.8'

services:
  web:
    build: ./web
    ports:
      - "80:80"
    environment:
      - NODE_ENV=production
    depends_on:
      - api
      - database

  api:
    build: ./api
    expose:
      - "3000"
    environment:
      - NODE_ENV=production
    depends_on:
      - database
      - redis

  database:
    image: postgres:13
    environment:
      POSTGRES_DB: myapp
      POSTGRES_USER: appuser
    volumes:
      - db_data:/var/lib/postgresql/data

  redis:
    image: redis:alpine
    command: redis-server --appendonly yes
    volumes:
      - redis_data:/data

volumes:
  db_data:
  redis_data:

networks:
  default:
    driver: bridge
```

## Hands-on Lab 1: Multi-Environment Web Application

Let's create a complete multi-environment setup for a web application.

### Step 1: Create Project Structure

```bash
mkdir multi-env-app
cd multi-env-app

# Create application directories
mkdir -p web api
mkdir -p config/{dev,staging,prod}
mkdir -p secrets/{dev,staging,prod}
mkdir -p data/init
```

### Step 2: Create Web Application

Create `web/Dockerfile`:

```dockerfile
FROM node:16-alpine as builder

WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production

COPY . .
RUN npm run build

FROM nginx:alpine
COPY --from=builder /app/dist /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Add environment detection
RUN echo '#!/bin/sh' > /docker-entrypoint.d/30-env-substitution.sh && \
    echo 'envsubst < /etc/nginx/conf.d/default.conf.template > /etc/nginx/conf.d/default.conf' >> /docker-entrypoint.d/30-env-substitution.sh && \
    chmod +x /docker-entrypoint.d/30-env-substitution.sh

EXPOSE 80
```

Create `web/package.json`:

```json
{
  "name": "multi-env-web",
  "version": "1.0.0",
  "scripts": {
    "build": "mkdir -p dist && echo '<h1>Multi-Environment App</h1><p>Environment: ${NODE_ENV}</p><div id=\"api-data\">Loading...</div><script>fetch(\"/api/health\").then(r=>r.json()).then(d=>document.getElementById(\"api-data\").innerHTML=JSON.stringify(d,null,2))</script>' > dist/index.html"
  }
}
```

Create `web/nginx.conf`:

```nginx
upstream api_backend {
    server ${API_HOST}:${API_PORT};
}

server {
    listen 80;
    server_name ${SERVER_NAME};
    root /usr/share/nginx/html;
    index index.html;

    # Security headers (production)
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;

    location / {
        try_files $uri $uri/ /index.html;
    }

    location /api/ {
        proxy_pass http://api_backend/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        
        # Environment-specific timeouts
        proxy_connect_timeout ${PROXY_TIMEOUT}s;
        proxy_send_timeout ${PROXY_TIMEOUT}s;
        proxy_read_timeout ${PROXY_TIMEOUT}s;
    }

    # Health check
    location /health {
        access_log off;
        return 200 "Web server healthy\n";
        add_header Content-Type text/plain;
    }
}
```

### Step 3: Create API Application

Create `api/Dockerfile`:

```dockerfile
FROM node:16-alpine

WORKDIR /app

# Install dependencies
COPY package*.json ./
RUN npm ci --only=production

# Copy source code
COPY . .

# Create non-root user
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nodejs -u 1001
USER nodejs

EXPOSE 3000
CMD ["node", "server.js"]
```

Create `api/package.json`:

```json
{
  "name": "multi-env-api",
  "version": "1.0.0",
  "main": "server.js",
  "dependencies": {
    "express": "^4.18.0",
    "pg": "^8.8.0",
    "redis": "^4.3.0",
    "helmet": "^6.0.0",
    "cors": "^2.8.5"
  }
}
```

Create `api/server.js`:

```javascript
const express = require('express');
const helmet = require('helmet');
const cors = require('cors');

const app = express();
const port = process.env.PORT || 3000;
const environment = process.env.NODE_ENV || 'development';

// Security middleware (production)
if (environment === 'production') {
  app.use(helmet());
}

// CORS configuration
const corsOptions = {
  origin: process.env.CORS_ORIGIN || '*',
  credentials: true
};
app.use(cors(corsOptions));

app.use(express.json());

// Environment info
const envInfo = {
  environment,
  version: process.env.APP_VERSION || '1.0.0',
  hostname: process.env.HOSTNAME,
  timestamp: new Date().toISOString()
};

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({
    status: 'healthy',
    ...envInfo,
    uptime: process.uptime(),
    memory: process.memoryUsage()
  });
});

// Environment-specific endpoint
app.get('/config', (req, res) => {
  res.json({
    environment,
    features: {
      debugging: environment !== 'production',
      analytics: environment === 'production',
      monitoring: ['staging', 'production'].includes(environment)
    },
    limits: {
      requestTimeout: process.env.REQUEST_TIMEOUT || 30000,
      maxConnections: process.env.MAX_CONNECTIONS || 100
    }
  });
});

// Database connection info (without credentials)
app.get('/database', (req, res) => {
  res.json({
    host: process.env.DB_HOST || 'localhost',
    database: process.env.DB_NAME || 'myapp',
    ssl: process.env.DB_SSL === 'true',
    poolSize: process.env.DB_POOL_SIZE || 10
  });
});

// Error handling
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({
    error: environment === 'production' ? 'Internal Server Error' : err.message,
    environment
  });
});

app.listen(port, () => {
  console.log(`API server running on port ${port} in ${environment} mode`);
});
```

### Step 4: Create Environment-Specific Configurations

Create `docker-compose.override.yml` (development):

```yaml
version: '3.8'

services:
  web:
    environment:
      - NODE_ENV=development
      - API_HOST=api
      - API_PORT=3000
      - SERVER_NAME=localhost
      - PROXY_TIMEOUT=30
    volumes:
      - ./web:/app
    ports:
      - "3001:80"  # Different port for dev

  api:
    environment:
      - NODE_ENV=development
      - DEBUG=true
      - DB_HOST=database
      - DB_NAME=myapp_dev
      - DB_USER=devuser
      - DB_PASSWORD=devpass
      - REDIS_URL=redis://redis:6379
      - CORS_ORIGIN=http://localhost:3001
    volumes:
      - ./api:/app
      - /app/node_modules
    command: npm run dev

  database:
    environment:
      POSTGRES_DB: myapp_dev
      POSTGRES_USER: devuser
      POSTGRES_PASSWORD: devpass
    ports:
      - "5432:5432"  # Expose for development tools

  redis:
    ports:
      - "6379:6379"  # Expose for development tools

  # Development tools
  adminer:
    image: adminer:latest
    ports:
      - "8080:8080"
    depends_on:
      - database

  redis-commander:
    image: rediscommander/redis-commander:latest
    environment:
      - REDIS_HOSTS=local:redis:6379
    ports:
      - "8081:8081"
    depends_on:
      - redis
```

Create `docker-compose.staging.yml`:

```yaml
version: '3.8'

services:
  web:
    environment:
      - NODE_ENV=staging
      - API_HOST=api
      - API_PORT=3000
      - SERVER_NAME=staging.myapp.com
      - PROXY_TIMEOUT=10
    deploy:
      replicas: 2
      resources:
        limits:
          cpus: '0.5'
          memory: 256M

  api:
    environment:
      - NODE_ENV=staging
      - DB_HOST=database
      - DB_NAME=myapp_staging
      - DB_USER=staginguser
      - DB_PASSWORD_FILE=/run/secrets/db_password
      - REDIS_URL=redis://redis:6379
      - CORS_ORIGIN=https://staging.myapp.com
      - REQUEST_TIMEOUT=15000
    deploy:
      replicas: 2
      resources:
        limits:
          cpus: '0.5'
          memory: 512M
    secrets:
      - db_password

  database:
    environment:
      POSTGRES_DB: myapp_staging
      POSTGRES_USER: staginguser
      POSTGRES_PASSWORD_FILE: /run/secrets/db_password
    deploy:
      resources:
        limits:
          cpus: '1'
          memory: 1G
    secrets:
      - db_password

  redis:
    deploy:
      resources:
        limits:
          cpus: '0.25'
          memory: 128M

  # Monitoring for staging
  prometheus:
    image: prom/prometheus:latest
    ports:
      - "9090:9090"
    volumes:
      - ./config/staging/prometheus.yml:/etc/prometheus/prometheus.yml

secrets:
  db_password:
    file: ./secrets/staging/db_password.txt
```

Create `docker-compose.prod.yml`:

```yaml
version: '3.8'

services:
  web:
    environment:
      - NODE_ENV=production
      - API_HOST=api
      - API_PORT=3000
      - SERVER_NAME=myapp.com
      - PROXY_TIMEOUT=5
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

  api:
    environment:
      - NODE_ENV=production
      - DB_HOST=database
      - DB_NAME=myapp_prod
      - DB_USER=produser
      - DB_PASSWORD_FILE=/run/secrets/db_password
      - REDIS_URL=redis://redis:6379
      - CORS_ORIGIN=https://myapp.com
      - REQUEST_TIMEOUT=10000
      - MAX_CONNECTIONS=200
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
    secrets:
      - db_password
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"

  database:
    environment:
      POSTGRES_DB: myapp_prod
      POSTGRES_USER: produser
      POSTGRES_PASSWORD_FILE: /run/secrets/db_password
    deploy:
      resources:
        limits:
          cpus: '2'
          memory: 2G
        reservations:
          cpus: '1'
          memory: 1G
    secrets:
      - db_password
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"

  redis:
    command: redis-server --appendonly yes --maxmemory 256mb --maxmemory-policy allkeys-lru
    deploy:
      resources:
        limits:
          cpus: '0.5'
          memory: 256M
        reservations:
          cpus: '0.25'
          memory: 128M

  # Production monitoring
  prometheus:
    image: prom/prometheus:latest
    ports:
      - "9090:9090"
    volumes:
      - ./config/prod/prometheus.yml:/etc/prometheus/prometheus.yml
      - prometheus_data:/prometheus
    deploy:
      resources:
        limits:
          cpus: '0.5'
          memory: 512M

  grafana:
    image: grafana/grafana:latest
    ports:
      - "3000:3000"
    environment:
      - GF_SECURITY_ADMIN_PASSWORD_FILE=/run/secrets/grafana_password
    volumes:
      - grafana_data:/var/lib/grafana
    secrets:
      - grafana_password
    depends_on:
      - prometheus

volumes:
  prometheus_data:
  grafana_data:

secrets:
  db_password:
    file: ./secrets/prod/db_password.txt
  grafana_password:
    file: ./secrets/prod/grafana_password.txt
```

### Step 5: Create Secret Files

```bash
# Development secrets (plain text for simplicity)
echo "devpass" > secrets/dev/db_password.txt

# Staging secrets
echo "staging_secure_password_123" > secrets/staging/db_password.txt

# Production secrets (would be managed by secret management system)
echo "production_very_secure_password_456" > secrets/prod/db_password.txt
echo "grafana_admin_password_789" > secrets/prod/grafana_password.txt

# Set appropriate permissions
chmod 600 secrets/*/
```

### Step 6: Create Environment-Specific Scripts

Create `scripts/deploy-dev.sh`:

```bash
#!/bin/bash
set -e

echo "Deploying to Development Environment..."

# Set environment
export COMPOSE_PROJECT_NAME=myapp_dev
export ENVIRONMENT=development

# Start development stack
docker-compose up -d

echo "Development environment started!"
echo "Web: http://localhost:3001"
echo "API: http://localhost:3001/api/health"
echo "Database Admin: http://localhost:8080"
echo "Redis Admin: http://localhost:8081"
```

Create `scripts/deploy-staging.sh`:

```bash
#!/bin/bash
set -e

echo "Deploying to Staging Environment..."

# Set environment
export COMPOSE_PROJECT_NAME=myapp_staging
export ENVIRONMENT=staging

# Build and deploy
docker-compose -f docker-compose.yml -f docker-compose.staging.yml build
docker-compose -f docker-compose.yml -f docker-compose.staging.yml up -d

echo "Staging environment deployed!"
echo "Monitoring: http://localhost:9090"
```

Create `scripts/deploy-prod.sh`:

```bash
#!/bin/bash
set -e

echo "Deploying to Production Environment..."

# Set environment
export COMPOSE_PROJECT_NAME=myapp_prod
export ENVIRONMENT=production

# Build images
docker-compose -f docker-compose.yml -f docker-compose.prod.yml build

# Deploy with zero downtime
docker-compose -f docker-compose.yml -f docker-compose.prod.yml up -d --no-deps web
docker-compose -f docker-compose.yml -f docker-compose.prod.yml up -d --no-deps api

echo "Production environment deployed!"
echo "Monitoring: http://localhost:9090"
echo "Grafana: http://localhost:3000"
```

## Docker Compose Profiles

Profiles allow you to selectively start services based on the environment.

### Using Profiles

Create `docker-compose.profiles.yml`:

```yaml
version: '3.8'

services:
  # Core services (always running)
  web:
    build: ./web
    ports:
      - "80:80"
    depends_on:
      - api

  api:
    build: ./api
    expose:
      - "3000"
    depends_on:
      - database

  database:
    image: postgres:13
    environment:
      POSTGRES_DB: myapp
      POSTGRES_USER: user
      POSTGRES_PASSWORD: pass

  # Development tools
  adminer:
    image: adminer:latest
    ports:
      - "8080:8080"
    depends_on:
      - database
    profiles:
      - dev
      - debug

  redis-commander:
    image: rediscommander/redis-commander:latest
    ports:
      - "8081:8081"
    profiles:
      - dev
      - debug

  # Testing services
  test-runner:
    build: ./tests
    volumes:
      - ./tests:/tests
    profiles:
      - testing

  # Monitoring services
  prometheus:
    image: prom/prometheus:latest
    ports:
      - "9090:9090"
    profiles:
      - monitoring
      - prod

  grafana:
    image: grafana/grafana:latest
    ports:
      - "3000:3000"
    depends_on:
      - prometheus
    profiles:
      - monitoring
      - prod

  # Load testing
  artillery:
    image: artilleryio/artillery:latest
    volumes:
      - ./load-tests:/scripts
    profiles:
      - load-testing
```

### Using Profiles

```bash
# Start core services only
docker-compose -f docker-compose.profiles.yml up -d

# Start with development tools
docker-compose -f docker-compose.profiles.yml --profile dev up -d

# Start with monitoring
docker-compose -f docker-compose.profiles.yml --profile monitoring up -d

# Start with multiple profiles
docker-compose -f docker-compose.profiles.yml --profile dev --profile monitoring up -d

# Production deployment
docker-compose -f docker-compose.profiles.yml --profile prod up -d
```

## Hands-on Lab 2: Configuration Management

Let's implement advanced configuration management with templates and validation.

### Step 1: Create Configuration Templates

Create `config/template.yml`:

```yaml
version: '3.8'

services:
  web:
    build: ./web
    ports:
      - "${WEB_PORT}:80"
    environment:
      - NODE_ENV=${ENVIRONMENT}
      - API_HOST=api
      - API_PORT=3000
      - SERVER_NAME=${SERVER_NAME}
      - PROXY_TIMEOUT=${PROXY_TIMEOUT}
    deploy:
      replicas: ${WEB_REPLICAS}
      resources:
        limits:
          cpus: '${WEB_CPU_LIMIT}'
          memory: ${WEB_MEMORY_LIMIT}

  api:
    build: ./api
    expose:
      - "3000"
    environment:
      - NODE_ENV=${ENVIRONMENT}
      - DB_HOST=database
      - DB_NAME=${DB_NAME}
      - DB_USER=${DB_USER}
      - DB_PASSWORD=${DB_PASSWORD}
      - REDIS_URL=redis://redis:6379
      - CORS_ORIGIN=${CORS_ORIGIN}
      - REQUEST_TIMEOUT=${REQUEST_TIMEOUT}
    deploy:
      replicas: ${API_REPLICAS}
      resources:
        limits:
          cpus: '${API_CPU_LIMIT}'
          memory: ${API_MEMORY_LIMIT}

  database:
    image: postgres:13
    environment:
      POSTGRES_DB: ${DB_NAME}
      POSTGRES_USER: ${DB_USER}
      POSTGRES_PASSWORD: ${DB_PASSWORD}
    volumes:
      - db_data:/var/lib/postgresql/data
    deploy:
      resources:
        limits:
          cpus: '${DB_CPU_LIMIT}'
          memory: ${DB_MEMORY_LIMIT}

  redis:
    image: redis:alpine
    command: redis-server --appendonly yes --maxmemory ${REDIS_MEMORY} --maxmemory-policy allkeys-lru
    volumes:
      - redis_data:/data

volumes:
  db_data:
  redis_data:
```

### Step 2: Create Environment Variable Files

Create `.env.dev`:

```bash
# Development Environment
ENVIRONMENT=development
WEB_PORT=3001
SERVER_NAME=localhost
PROXY_TIMEOUT=30

# Scaling
WEB_REPLICAS=1
API_REPLICAS=1

# Resources
WEB_CPU_LIMIT=0.5
WEB_MEMORY_LIMIT=256M
API_CPU_LIMIT=0.5
API_MEMORY_LIMIT=512M
DB_CPU_LIMIT=1
DB_MEMORY_LIMIT=1G
REDIS_MEMORY=128mb

# Database
DB_NAME=myapp_dev
DB_USER=devuser
DB_PASSWORD=devpass

# API
CORS_ORIGIN=http://localhost:3001
REQUEST_TIMEOUT=30000
```

Create `.env.staging`:

```bash
# Staging Environment
ENVIRONMENT=staging
WEB_PORT=80
SERVER_NAME=staging.myapp.com
PROXY_TIMEOUT=10

# Scaling
WEB_REPLICAS=2
API_REPLICAS=2

# Resources
WEB_CPU_LIMIT=0.5
WEB_MEMORY_LIMIT=256M
API_CPU_LIMIT=0.5
API_MEMORY_LIMIT=512M
DB_CPU_LIMIT=1
DB_MEMORY_LIMIT=1G
REDIS_MEMORY=256mb

# Database
DB_NAME=myapp_staging
DB_USER=staginguser
DB_PASSWORD=staging_secure_password_123

# API
CORS_ORIGIN=https://staging.myapp.com
REQUEST_TIMEOUT=15000
```

Create `.env.prod`:

```bash
# Production Environment
ENVIRONMENT=production
WEB_PORT=80
SERVER_NAME=myapp.com
PROXY_TIMEOUT=5

# Scaling
WEB_REPLICAS=3
API_REPLICAS=3

# Resources
WEB_CPU_LIMIT=1
WEB_MEMORY_LIMIT=512M
API_CPU_LIMIT=1
API_MEMORY_LIMIT=1G
DB_CPU_LIMIT=2
DB_MEMORY_LIMIT=2G
REDIS_MEMORY=512mb

# Database
DB_NAME=myapp_prod
DB_USER=produser
DB_PASSWORD=production_very_secure_password_456

# API
CORS_ORIGIN=https://myapp.com
REQUEST_TIMEOUT=10000
```

### Step 3: Create Configuration Validation Script

Create `scripts/validate-config.sh`:

```bash
#!/bin/bash

ENV_FILE=$1

if [ -z "$ENV_FILE" ]; then
    echo "Usage: $0 <env-file>"
    exit 1
fi

if [ ! -f "$ENV_FILE" ]; then
    echo "Environment file $ENV_FILE not found!"
    exit 1
fi

echo "Validating configuration for $ENV_FILE..."

# Source the environment file
source "$ENV_FILE"

# Required variables
REQUIRED_VARS=(
    "ENVIRONMENT"
    "WEB_PORT"
    "SERVER_NAME"
    "DB_NAME"
    "DB_USER"
    "DB_PASSWORD"
    "CORS_ORIGIN"
)

# Check required variables
for var in "${REQUIRED_VARS[@]}"; do
    if [ -z "${!var}" ]; then
        echo "ERROR: Required variable $var is not set!"
        exit 1
    fi
done

# Validate numeric values
if ! [[ "$WEB_REPLICAS" =~ ^[0-9]+$ ]]; then
    echo "ERROR: WEB_REPLICAS must be a number!"
    exit 1
fi

if ! [[ "$API_REPLICAS" =~ ^[0-9]+$ ]]; then
    echo "ERROR: API_REPLICAS must be a number!"
    exit 1
fi

# Validate memory formats
if ! [[ "$WEB_MEMORY_LIMIT" =~ ^[0-9]+[MG]$ ]]; then
    echo "ERROR: WEB_MEMORY_LIMIT must be in format like 256M or 1G!"
    exit 1
fi

# Validate environment-specific settings
case "$ENVIRONMENT" in
    "development")
        if [ "$WEB_REPLICAS" -gt 1 ]; then
            echo "WARNING: Multiple replicas in development environment"
        fi
        ;;
    "production")
        if [ "$WEB_REPLICAS" -lt 2 ]; then
            echo "ERROR: Production environment should have at least 2 replicas!"
            exit 1
        fi
        if [[ "$DB_PASSWORD" == *"dev"* ]] || [[ "$DB_PASSWORD" == *"test"* ]]; then
            echo "ERROR: Production password appears to be a development password!"
            exit 1
        fi
        ;;
esac

echo "Configuration validation passed!"
```

### Step 4: Create Deployment Script

Create `scripts/deploy.sh`:

```bash
#!/bin/bash
set -e

ENVIRONMENT=$1
COMPOSE_FILE="config/template.yml"

if [ -z "$ENVIRONMENT" ]; then
    echo "Usage: $0 <environment>"
    echo "Available environments: dev, staging, prod"
    exit 1
fi

ENV_FILE=".env.$ENVIRONMENT"

# Validate configuration
./scripts/validate-config.sh "$ENV_FILE"

# Set project name
export COMPOSE_PROJECT_NAME="myapp_$ENVIRONMENT"

echo "Deploying to $ENVIRONMENT environment..."

# Load environment variables
export $(cat "$ENV_FILE" | xargs)

# Build and deploy
docker-compose -f "$COMPOSE_FILE" build
docker-compose -f "$COMPOSE_FILE" up -d

echo "Deployment completed!"
echo "Environment: $ENVIRONMENT"
echo "Web URL: http://$SERVER_NAME:$WEB_PORT"
echo "API Health: http://$SERVER_NAME:$WEB_PORT/api/health"
```

### Step 5: Test Multi-Environment Deployment

```bash
# Make scripts executable
chmod +x scripts/*.sh

# Deploy to development
./scripts/deploy.sh dev

# Deploy to staging
./scripts/deploy.sh staging

# Deploy to production
./scripts/deploy.sh prod

# Check running environments
docker ps --format "table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}"
```

## Advanced Configuration Patterns

### 1. External Configuration Service

Create `docker-compose.config-service.yml`:

```yaml
version: '3.8'

services:
  config-server:
    image: consul:latest
    ports:
      - "8500:8500"
    volumes:
      - consul_data:/consul/data
    command: consul agent -server -bootstrap -ui -client=0.0.0.0

  app:
    build: ./app
    environment:
      - CONFIG_URL=http://config-server:8500
    depends_on:
      - config-server

volumes:
  consul_data:
```

### 2. Dynamic Configuration Updates

```javascript
// In your application
const consul = require('consul')();

async function loadConfig() {
  try {
    const result = await consul.kv.get('app/config');
    return JSON.parse(result.Value);
  } catch (error) {
    console.error('Failed to load config:', error);
    return defaultConfig;
  }
}

// Watch for configuration changes
consul.watch({
  method: consul.kv.get,
  key: 'app/config'
}).on('change', (data) => {
  console.log('Configuration updated:', data);
  updateAppConfig(JSON.parse(data.Value));
});
```

### 3. Blue-Green Deployments

Create `scripts/blue-green-deploy.sh`:

```bash
#!/bin/bash
set -e

ENVIRONMENT=$1
NEW_VERSION=$2

if [ -z "$ENVIRONMENT" ] || [ -z "$NEW_VERSION" ]; then
    echo "Usage: $0 <environment> <version>"
    exit 1
fi

# Deploy to green environment
export COMPOSE_PROJECT_NAME="myapp_${ENVIRONMENT}_green"
export APP_VERSION="$NEW_VERSION"

echo "Deploying version $NEW_VERSION to green environment..."
docker-compose -f docker-compose.yml up -d

# Health check
echo "Performing health checks..."
sleep 30

if curl -f "http://localhost/health"; then
    echo "Green environment is healthy. Switching traffic..."
    
    # Switch traffic (update load balancer configuration)
    # This would typically involve updating nginx config or DNS
    
    # Stop blue environment
    export COMPOSE_PROJECT_NAME="myapp_${ENVIRONMENT}_blue"
    docker-compose -f docker-compose.yml down
    
    echo "Blue-green deployment completed successfully!"
else
    echo "Health check failed. Rolling back..."
    export COMPOSE_PROJECT_NAME="myapp_${ENVIRONMENT}_green"
    docker-compose -f docker-compose.yml down
    exit 1
fi
```

## Best Practices for Multi-Environment Deployments

### 1. Configuration Management

- **Use environment variables** for configuration
- **Validate configurations** before deployment
- **Keep secrets separate** from configuration files
- **Use configuration templates** for consistency

### 2. Security

```yaml
# Use secrets for sensitive data
secrets:
  db_password:
    external: true  # Managed by external system

services:
  database:
    environment:
      POSTGRES_PASSWORD_FILE: /run/secrets/db_password
    secrets:
      - db_password
```

- **Never commit secrets** to version control
- **Use external secret management** systems in production
- **Rotate secrets regularly**
- **Limit secret access** to necessary services only

### 3. Resource Management

```yaml
services:
  app:
    deploy:
      resources:
        limits:
          cpus: '${CPU_LIMIT}'
          memory: ${MEMORY_LIMIT}
        reservations:
          cpus: '${CPU_RESERVATION}'
          memory: ${MEMORY_RESERVATION}
```

### 4. Monitoring and Logging

```yaml
services:
  app:
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"
        labels: "environment=${ENVIRONMENT}"
```

### 5. Health Checks

```yaml
services:
  app:
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s
```

## Environment Promotion Pipeline

### Automated Promotion Script

Create `scripts/promote.sh`:

```bash
#!/bin/bash
set -e

SOURCE_ENV=$1
TARGET_ENV=$2

if [ -z "$SOURCE_ENV" ] || [ -z "$TARGET_ENV" ]; then
    echo "Usage: $0 <source-env> <target-env>"
    echo "Example: $0 staging prod"
    exit 1
fi

echo "Promoting from $SOURCE_ENV to $TARGET_ENV..."

# Get current image tags from source environment
SOURCE_PROJECT="myapp_$SOURCE_ENV"
TARGET_PROJECT="myapp_$TARGET_ENV"

# Extract image versions
WEB_IMAGE=$(docker-compose -p $SOURCE_PROJECT ps -q web | head -1 | xargs docker inspect --format='{{.Config.Image}}')
API_IMAGE=$(docker-compose -p $SOURCE_PROJECT ps -q api | head -1 | xargs docker inspect --format='{{.Config.Image}}')

echo "Promoting images:"
echo "  Web: $WEB_IMAGE"
echo "  API: $API_IMAGE"

# Tag images for target environment
docker tag $WEB_IMAGE "myapp/web:$TARGET_ENV"
docker tag $API_IMAGE "myapp/api:$TARGET_ENV"

# Deploy to target environment
export COMPOSE_PROJECT_NAME=$TARGET_PROJECT
export WEB_IMAGE="myapp/web:$TARGET_ENV"
export API_IMAGE="myapp/api:$TARGET_ENV"

# Load target environment configuration
source ".env.$TARGET_ENV"

# Deploy
docker-compose -f config/template.yml up -d

echo "Promotion completed successfully!"
```

## CI/CD Integration

### GitHub Actions Example

Create `.github/workflows/deploy.yml`:

```yaml
name: Deploy Multi-Environment

on:
  push:
    branches: [main, staging, develop]
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Run tests
        run: |
          docker-compose -f docker-compose.yml -f docker-compose.test.yml run --rm test

  deploy-dev:
    if: github.ref == 'refs/heads/develop'
    needs: test
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Deploy to Development
        run: |
          ./scripts/deploy.sh dev

  deploy-staging:
    if: github.ref == 'refs/heads/staging'
    needs: test
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Deploy to Staging
        run: |
          ./scripts/deploy.sh staging
          
      - name: Run integration tests
        run: |
          ./scripts/integration-tests.sh staging

  deploy-prod:
    if: github.ref == 'refs/heads/main'
    needs: test
    runs-on: ubuntu-latest
    environment: production
    steps:
      - uses: actions/checkout@v3
      
      - name: Deploy to Production
        run: |
          ./scripts/deploy.sh prod
          
      - name: Run smoke tests
        run: |
          ./scripts/smoke-tests.sh prod
```

## Configuration Drift Detection

Create `scripts/config-drift.sh`:

```bash
#!/bin/bash

# Check for configuration drift between environments
ENV1=$1
ENV2=$2

if [ -z "$ENV1" ] || [ -z "$ENV2" ]; then
    echo "Usage: $0 <env1> <env2>"
    exit 1
fi

echo "Checking configuration drift between $ENV1 and $ENV2..."

# Compare environment files
echo "=== Environment Variables ==="
diff -u ".env.$ENV1" ".env.$ENV2" || true

# Compare running configurations
echo "=== Running Container Configurations ==="
docker-compose -p "myapp_$ENV1" config > "/tmp/config_$ENV1.yml"
docker-compose -p "myapp_$ENV2" config > "/tmp/config_$ENV2.yml"

diff -u "/tmp/config_$ENV1.yml" "/tmp/config_$ENV2.yml" || true

# Cleanup
rm -f "/tmp/config_$ENV1.yml" "/tmp/config_$ENV2.yml"
```

## Troubleshooting Multi-Environment Issues

### Common Issues and Solutions

1. **Port Conflicts**
   ```bash
   # Check port usage
   netstat -tulpn | grep :80
   
   # Use different ports per environment
   WEB_PORT=3001  # dev
   WEB_PORT=3002  # staging
   WEB_PORT=80    # prod
   ```

2. **Resource Conflicts**
   ```bash
   # Check resource usage
   docker stats
   
   # Adjust resource limits per environment
   ```

3. **Network Issues**
   ```bash
   # Check network connectivity
   docker-compose exec web ping api
   
   # Verify DNS resolution
   docker-compose exec web nslookup api
   ```

4. **Volume Conflicts**
   ```bash
   # Use environment-specific volume names
   volumes:
     - "db_data_${ENVIRONMENT}:/var/lib/postgresql/data"
   ```

### Environment Health Check Script

Create `scripts/health-check.sh`:

```bash
#!/bin/bash

ENVIRONMENT=$1

if [ -z "$ENVIRONMENT" ]; then
    echo "Usage: $0 <environment>"
    exit 1
fi

PROJECT_NAME="myapp_$ENVIRONMENT"

echo "Health checking $ENVIRONMENT environment..."

# Check if services are running
SERVICES=$(docker-compose -p $PROJECT_NAME ps --services)
FAILED_SERVICES=""

for service in $SERVICES; do
    STATUS=$(docker-compose -p $PROJECT_NAME ps -q $service | xargs docker inspect --format='{{.State.Status}}' 2>/dev/null)
    
    if [ "$STATUS" != "running" ]; then
        FAILED_SERVICES="$FAILED_SERVICES $service"
        echo "❌ $service: $STATUS"
    else
        echo "✅ $service: running"
    fi
done

# Check health endpoints
if docker-compose -p $PROJECT_NAME ps -q web >/dev/null 2>&1; then
    WEB_PORT=$(docker-compose -p $PROJECT_NAME port web 80 2>/dev/null | cut -d: -f2)
    if [ -n "$WEB_PORT" ]; then
        if curl -f "http://localhost:$WEB_PORT/health" >/dev/null 2>&1; then
            echo "✅ Web health check: passed"
        else
            echo "❌ Web health check: failed"
            FAILED_SERVICES="$FAILED_SERVICES web-health"
        fi
    fi
fi

if [ -n "$FAILED_SERVICES" ]; then
    echo "❌ Health check failed for:$FAILED_SERVICES"
    exit 1
else
    echo "✅ All health checks passed!"
fi
```

## Summary

In this lesson, you learned:
- How to configure applications for multiple environments
- Using Docker Compose override files and profiles
- Managing environment-specific configurations and secrets
- Implementing configuration templating and validation
- Deploying across different environments safely
- Best practices for multi-environment deployments
- Troubleshooting common multi-environment issues

## Next Steps
- Practice deploying to different environments
- Set up automated promotion pipelines
- Implement configuration drift detection
- Move on to Lesson 5: Troubleshooting and Best Practices

## Additional Resources
- [Docker Compose Override Files](https://docs.docker.com/compose/extends/)
- [Docker Compose Profiles](https://docs.docker.com/compose/profiles/)
- [Environment Variable Substitution](https://docs.docker.com/compose/environment-variables/)
- [Docker Secrets Management](https://docs.docker.com/engine/swarm/secrets/)
- [Configuration Management Best Practices](https://12factor.net/config)
