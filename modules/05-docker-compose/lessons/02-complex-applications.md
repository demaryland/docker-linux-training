# Lesson 2: Building Complex Applications

## Learning Objectives
By the end of this lesson, you will be able to:
- Design multi-service application architectures
- Implement service communication patterns
- Manage complex environment configurations
- Handle build contexts and custom images
- Implement proper logging and monitoring
- Create production-ready application stacks

## Prerequisites
- Completed Lesson 1: Compose Basics
- Understanding of application architecture patterns
- Knowledge of web services and APIs

## Multi-Service Architecture Patterns

### 1. Three-Tier Architecture

The classic web application pattern with presentation, business logic, and data layers:

```yaml
version: '3.8'

services:
  # Presentation Layer
  frontend:
    build: ./frontend
    ports:
      - "80:80"
    depends_on:
      - backend
    networks:
      - frontend-network

  # Business Logic Layer
  backend:
    build: ./backend
    expose:
      - "3000"
    depends_on:
      - database
      - cache
    networks:
      - frontend-network
      - backend-network

  # Data Layer
  database:
    image: postgres:13
    environment:
      POSTGRES_DB: myapp
      POSTGRES_USER: appuser
      POSTGRES_PASSWORD: apppass
    volumes:
      - db_data:/var/lib/postgresql/data
    networks:
      - backend-network

  cache:
    image: redis:alpine
    networks:
      - backend-network

volumes:
  db_data:

networks:
  frontend-network:
  backend-network:
```

### 2. Microservices Architecture

Breaking down functionality into independent services:

```yaml
version: '3.8'

services:
  # API Gateway
  gateway:
    image: nginx:alpine
    ports:
      - "80:80"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf
    depends_on:
      - user-service
      - order-service
      - product-service
    networks:
      - public

  # User Management Service
  user-service:
    build: ./services/user
    environment:
      - DATABASE_URL=postgresql://users_db:5432/users
    depends_on:
      - users-db
    networks:
      - public
      - user-network

  # Order Management Service
  order-service:
    build: ./services/order
    environment:
      - DATABASE_URL=postgresql://orders_db:5432/orders
      - USER_SERVICE_URL=http://user-service:3000
    depends_on:
      - orders-db
    networks:
      - public
      - order-network

  # Product Catalog Service
  product-service:
    build: ./services/product
    environment:
      - DATABASE_URL=postgresql://products_db:5432/products
    depends_on:
      - products-db
    networks:
      - public
      - product-network

  # Databases
  users-db:
    image: postgres:13
    environment:
      POSTGRES_DB: users
      POSTGRES_USER: userservice
      POSTGRES_PASSWORD: userpass
    volumes:
      - users_data:/var/lib/postgresql/data
    networks:
      - user-network

  orders-db:
    image: postgres:13
    environment:
      POSTGRES_DB: orders
      POSTGRES_USER: orderservice
      POSTGRES_PASSWORD: orderpass
    volumes:
      - orders_data:/var/lib/postgresql/data
    networks:
      - order-network

  products-db:
    image: postgres:13
    environment:
      POSTGRES_DB: products
      POSTGRES_USER: productservice
      POSTGRES_PASSWORD: productpass
    volumes:
      - products_data:/var/lib/postgresql/data
    networks:
      - product-network

volumes:
  users_data:
  orders_data:
  products_data:

networks:
  public:
  user-network:
  order-network:
  product-network:
```

## Hands-on Lab 1: E-commerce Platform

Let's build a complete e-commerce platform with multiple services.

### Step 1: Create Project Structure

```bash
mkdir ecommerce-platform
cd ecommerce-platform

# Create service directories
mkdir -p frontend backend admin-panel
mkdir -p services/{user,product,order,payment}
mkdir -p config/nginx
mkdir -p data/init
```

### Step 2: Create Frontend Service

Create `frontend/Dockerfile`:

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
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
```

Create `frontend/package.json`:

```json
{
  "name": "ecommerce-frontend",
  "version": "1.0.0",
  "scripts": {
    "build": "echo 'Building frontend...' && mkdir -p dist && echo '<h1>E-commerce Frontend</h1><p>Connected to API</p>' > dist/index.html",
    "dev": "echo 'Development server would start here'"
  }
}
```

Create `frontend/nginx.conf`:

```nginx
server {
    listen 80;
    server_name localhost;
    root /usr/share/nginx/html;
    index index.html;

    # Frontend routes
    location / {
        try_files $uri $uri/ /index.html;
    }

    # API proxy
    location /api/ {
        proxy_pass http://backend:3000/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    # Admin panel proxy
    location /admin/ {
        proxy_pass http://admin-panel:4000/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```

### Step 3: Create Backend API

Create `backend/Dockerfile`:

```dockerfile
FROM node:16-alpine

WORKDIR /app

# Install dependencies
COPY package*.json ./
RUN npm ci --only=production

# Copy source code
COPY . .

# Create non-root user
RUN addgroup -g 1001 -S nodejs
RUN adduser -S nodejs -u 1001
USER nodejs

EXPOSE 3000
CMD ["node", "server.js"]
```

Create `backend/package.json`:

```json
{
  "name": "ecommerce-backend",
  "version": "1.0.0",
  "main": "server.js",
  "dependencies": {
    "express": "^4.18.0",
    "cors": "^2.8.5",
    "helmet": "^6.0.0",
    "morgan": "^1.10.0",
    "pg": "^8.8.0",
    "redis": "^4.3.0",
    "bcrypt": "^5.1.0",
    "jsonwebtoken": "^8.5.1"
  }
}
```

Create `backend/server.js`:

```javascript
const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');

const app = express();
const port = process.env.PORT || 3000;

// Middleware
app.use(helmet());
app.use(cors());
app.use(morgan('combined'));
app.use(express.json());

// Health check
app.get('/health', (req, res) => {
  res.json({ 
    status: 'healthy', 
    timestamp: new Date().toISOString(),
    service: 'ecommerce-backend'
  });
});

// API Routes
app.get('/users', (req, res) => {
  res.json({ message: 'Users endpoint', users: [] });
});

app.get('/products', (req, res) => {
  res.json({ 
    message: 'Products endpoint', 
    products: [
      { id: 1, name: 'Sample Product', price: 29.99 },
      { id: 2, name: 'Another Product', price: 49.99 }
    ]
  });
});

app.get('/orders', (req, res) => {
  res.json({ message: 'Orders endpoint', orders: [] });
});

// Error handling
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({ error: 'Something went wrong!' });
});

app.listen(port, () => {
  console.log(`Backend server running on port ${port}`);
});
```

### Step 4: Create Admin Panel

Create `admin-panel/Dockerfile`:

```dockerfile
FROM python:3.9-slim

WORKDIR /app

# Install dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application
COPY . .

# Create non-root user
RUN useradd --create-home --shell /bin/bash admin
USER admin

EXPOSE 4000
CMD ["python", "app.py"]
```

Create `admin-panel/requirements.txt`:

```txt
Flask==2.3.0
Flask-CORS==4.0.0
psycopg2-binary==2.9.7
redis==4.6.0
```

Create `admin-panel/app.py`:

```python
from flask import Flask, jsonify, request
from flask_cors import CORS
import os

app = Flask(__name__)
CORS(app)

@app.route('/health')
def health():
    return jsonify({
        'status': 'healthy',
        'service': 'admin-panel'
    })

@app.route('/dashboard')
def dashboard():
    return jsonify({
        'message': 'Admin Dashboard',
        'stats': {
            'total_users': 150,
            'total_orders': 75,
            'total_products': 25,
            'revenue': 15750.50
        }
    })

@app.route('/users')
def admin_users():
    return jsonify({
        'users': [
            {'id': 1, 'name': 'John Doe', 'email': 'john@example.com'},
            {'id': 2, 'name': 'Jane Smith', 'email': 'jane@example.com'}
        ]
    })

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=4000, debug=True)
```

### Step 5: Create Docker Compose Configuration

Create `docker-compose.yml`:

```yaml
version: '3.8'

services:
  # Frontend Service
  frontend:
    build: ./frontend
    ports:
      - "80:80"
    depends_on:
      - backend
      - admin-panel
    networks:
      - frontend-network
    restart: unless-stopped

  # Backend API Service
  backend:
    build: ./backend
    environment:
      - NODE_ENV=production
      - PORT=3000
      - DATABASE_URL=postgresql://api_user:api_pass@postgres:5432/ecommerce
      - REDIS_URL=redis://redis:6379
      - JWT_SECRET=your-super-secret-jwt-key
    depends_on:
      postgres:
        condition: service_healthy
      redis:
        condition: service_started
    networks:
      - frontend-network
      - backend-network
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:3000/health"]
      interval: 30s
      timeout: 10s
      retries: 3

  # Admin Panel Service
  admin-panel:
    build: ./admin-panel
    environment:
      - FLASK_ENV=production
      - DATABASE_URL=postgresql://admin_user:admin_pass@postgres:5432/ecommerce
      - REDIS_URL=redis://redis:6379
    depends_on:
      postgres:
        condition: service_healthy
    networks:
      - frontend-network
      - backend-network
    restart: unless-stopped

  # Database Service
  postgres:
    image: postgres:13
    environment:
      POSTGRES_DB: ecommerce
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: postgres_pass
    volumes:
      - postgres_data:/var/lib/postgresql/data
      - ./data/init:/docker-entrypoint-initdb.d
    networks:
      - backend-network
    restart: unless-stopped
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres"]
      interval: 30s
      timeout: 10s
      retries: 5

  # Cache Service
  redis:
    image: redis:alpine
    command: redis-server --appendonly yes
    volumes:
      - redis_data:/data
    networks:
      - backend-network
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 30s
      timeout: 10s
      retries: 3

  # Message Queue
  rabbitmq:
    image: rabbitmq:3-management
    environment:
      RABBITMQ_DEFAULT_USER: admin
      RABBITMQ_DEFAULT_PASS: admin_pass
    ports:
      - "15672:15672"  # Management UI
    volumes:
      - rabbitmq_data:/var/lib/rabbitmq
    networks:
      - backend-network
    restart: unless-stopped

  # Monitoring
  prometheus:
    image: prom/prometheus:latest
    ports:
      - "9090:9090"
    volumes:
      - ./config/prometheus.yml:/etc/prometheus/prometheus.yml
      - prometheus_data:/prometheus
    networks:
      - monitoring-network
    restart: unless-stopped

  grafana:
    image: grafana/grafana:latest
    ports:
      - "3001:3000"
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=admin
    volumes:
      - grafana_data:/var/lib/grafana
    depends_on:
      - prometheus
    networks:
      - monitoring-network
    restart: unless-stopped

volumes:
  postgres_data:
  redis_data:
  rabbitmq_data:
  prometheus_data:
  grafana_data:

networks:
  frontend-network:
    driver: bridge
  backend-network:
    driver: bridge
  monitoring-network:
    driver: bridge
```

### Step 6: Create Database Initialization

Create `data/init/01-create-users.sql`:

```sql
-- Create application users
CREATE USER api_user WITH PASSWORD 'api_pass';
CREATE USER admin_user WITH PASSWORD 'admin_pass';

-- Grant permissions
GRANT CONNECT ON DATABASE ecommerce TO api_user;
GRANT CONNECT ON DATABASE ecommerce TO admin_user;

-- Create schemas
CREATE SCHEMA IF NOT EXISTS api;
CREATE SCHEMA IF NOT EXISTS admin;

GRANT USAGE ON SCHEMA api TO api_user;
GRANT USAGE ON SCHEMA admin TO admin_user;
GRANT CREATE ON SCHEMA api TO api_user;
GRANT CREATE ON SCHEMA admin TO admin_user;
```

Create `data/init/02-create-tables.sql`:

```sql
-- Users table
CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Products table
CREATE TABLE IF NOT EXISTS products (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    price DECIMAL(10,2) NOT NULL,
    stock_quantity INTEGER DEFAULT 0,
    category_id INTEGER,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Orders table
CREATE TABLE IF NOT EXISTS orders (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id),
    total_amount DECIMAL(10,2) NOT NULL,
    status VARCHAR(50) DEFAULT 'pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Order items table
CREATE TABLE IF NOT EXISTS order_items (
    id SERIAL PRIMARY KEY,
    order_id INTEGER REFERENCES orders(id),
    product_id INTEGER REFERENCES products(id),
    quantity INTEGER NOT NULL,
    price DECIMAL(10,2) NOT NULL
);

-- Insert sample data
INSERT INTO users (email, password_hash, first_name, last_name) VALUES
    ('john@example.com', '$2b$10$hash1', 'John', 'Doe'),
    ('jane@example.com', '$2b$10$hash2', 'Jane', 'Smith');

INSERT INTO products (name, description, price, stock_quantity) VALUES
    ('Laptop', 'High-performance laptop', 999.99, 50),
    ('Mouse', 'Wireless mouse', 29.99, 200),
    ('Keyboard', 'Mechanical keyboard', 79.99, 100);
```

### Step 7: Create Monitoring Configuration

Create `config/prometheus.yml`:

```yaml
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'backend'
    static_configs:
      - targets: ['backend:3000']
    metrics_path: '/metrics'
    scrape_interval: 30s

  - job_name: 'admin-panel'
    static_configs:
      - targets: ['admin-panel:4000']
    metrics_path: '/metrics'
    scrape_interval: 30s

  - job_name: 'postgres'
    static_configs:
      - targets: ['postgres:5432']
    scrape_interval: 30s

  - job_name: 'redis'
    static_configs:
      - targets: ['redis:6379']
    scrape_interval: 30s
```

### Step 8: Deploy the Platform

```bash
# Build and start all services
docker-compose up -d

# Check service status
docker-compose ps

# View logs
docker-compose logs -f backend

# Test the application
curl http://localhost/api/health
curl http://localhost/api/products

# Access services:
# Frontend: http://localhost
# Admin Panel: http://localhost/admin/dashboard
# RabbitMQ Management: http://localhost:15672 (admin/admin_pass)
# Prometheus: http://localhost:9090
# Grafana: http://localhost:3001 (admin/admin)
```

## Advanced Configuration Patterns

### 1. Environment-Specific Configurations

Create `docker-compose.override.yml` for development:

```yaml
version: '3.8'

services:
  backend:
    environment:
      - NODE_ENV=development
      - DEBUG=true
    volumes:
      - ./backend:/app
      - /app/node_modules
    command: npm run dev

  admin-panel:
    environment:
      - FLASK_ENV=development
      - FLASK_DEBUG=1
    volumes:
      - ./admin-panel:/app

  frontend:
    volumes:
      - ./frontend/src:/app/src
```

### 2. Secrets Management

Create `secrets/db_password.txt`:

```txt
super_secure_database_password
```

Update compose file:

```yaml
version: '3.8'

services:
  postgres:
    image: postgres:13
    environment:
      POSTGRES_PASSWORD_FILE: /run/secrets/db_password
    secrets:
      - db_password

secrets:
  db_password:
    file: ./secrets/db_password.txt
```

### 3. Resource Limits

```yaml
services:
  backend:
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

### 4. Logging Configuration

```yaml
services:
  backend:
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"
        labels: "service=backend"
```

## Service Communication Patterns

### 1. Synchronous Communication (HTTP)

```javascript
// In backend service
const axios = require('axios');

async function getUserProfile(userId) {
  try {
    const response = await axios.get(`http://user-service:3000/users/${userId}`);
    return response.data;
  } catch (error) {
    console.error('Failed to fetch user profile:', error.message);
    throw error;
  }
}
```

### 2. Asynchronous Communication (Message Queue)

```javascript
// Publisher (Order Service)
const amqp = require('amqplib');

async function publishOrderEvent(orderData) {
  const connection = await amqp.connect('amqp://rabbitmq:5672');
  const channel = await connection.createChannel();
  
  await channel.assertQueue('order.created');
  channel.sendToQueue('order.created', Buffer.from(JSON.stringify(orderData)));
  
  await channel.close();
  await connection.close();
}

// Consumer (Email Service)
async function consumeOrderEvents() {
  const connection = await amqp.connect('amqp://rabbitmq:5672');
  const channel = await connection.createChannel();
  
  await channel.assertQueue('order.created');
  channel.consume('order.created', (message) => {
    const orderData = JSON.parse(message.content.toString());
    console.log('Processing order:', orderData);
    // Send confirmation email
    channel.ack(message);
  });
}
```

### 3. Database Per Service Pattern

```yaml
services:
  user-service:
    build: ./services/user
    depends_on:
      - user-db
  
  user-db:
    image: postgres:13
    environment:
      POSTGRES_DB: users
    volumes:
      - user_data:/var/lib/postgresql/data

  order-service:
    build: ./services/order
    depends_on:
      - order-db
  
  order-db:
    image: postgres:13
    environment:
      POSTGRES_DB: orders
    volumes:
      - order_data:/var/lib/postgresql/data
```

## Hands-on Lab 2: Microservices with API Gateway

Let's implement a proper microservices architecture with an API gateway.

### Step 1: Create API Gateway

Create `gateway/nginx.conf`:

```nginx
upstream user-service {
    server user-service:3000;
}

upstream product-service {
    server product-service:3001;
}

upstream order-service {
    server order-service:3002;
}

server {
    listen 80;
    
    # Rate limiting
    limit_req_zone $binary_remote_addr zone=api:10m rate=10r/s;
    
    # User service routes
    location /api/users {
        limit_req zone=api burst=20 nodelay;
        proxy_pass http://user-service;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
    
    # Product service routes
    location /api/products {
        limit_req zone=api burst=20 nodelay;
        proxy_pass http://product-service;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
    
    # Order service routes
    location /api/orders {
        limit_req zone=api burst=20 nodelay;
        proxy_pass http://order-service;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
    
    # Health check endpoint
    location /health {
        access_log off;
        return 200 "healthy\n";
        add_header Content-Type text/plain;
    }
}
```

### Step 2: Create Microservices Compose File

Create `docker-compose.microservices.yml`:

```yaml
version: '3.8'

services:
  # API Gateway
  api-gateway:
    image: nginx:alpine
    ports:
      - "80:80"
    volumes:
      - ./gateway/nginx.conf:/etc/nginx/conf.d/default.conf
    depends_on:
      - user-service
      - product-service
      - order-service
    networks:
      - gateway-network

  # User Service
  user-service:
    build: ./services/user
    environment:
      - DATABASE_URL=postgresql://user_db:5432/users
      - REDIS_URL=redis://redis:6379
    depends_on:
      - user-db
      - redis
    networks:
      - gateway-network
      - user-network

  # Product Service
  product-service:
    build: ./services/product
    environment:
      - DATABASE_URL=postgresql://product_db:5432/products
      - REDIS_URL=redis://redis:6379
    depends_on:
      - product-db
      - redis
    networks:
      - gateway-network
      - product-network

  # Order Service
  order-service:
    build: ./services/order
    environment:
      - DATABASE_URL=postgresql://order_db:5432/orders
      - USER_SERVICE_URL=http://user-service:3000
      - PRODUCT_SERVICE_URL=http://product-service:3001
      - RABBITMQ_URL=amqp://rabbitmq:5672
    depends_on:
      - order-db
      - rabbitmq
    networks:
      - gateway-network
      - order-network

  # Databases
  user-db:
    image: postgres:13
    environment:
      POSTGRES_DB: users
      POSTGRES_USER: userservice
      POSTGRES_PASSWORD: userpass
    volumes:
      - user_data:/var/lib/postgresql/data
    networks:
      - user-network

  product-db:
    image: postgres:13
    environment:
      POSTGRES_DB: products
      POSTGRES_USER: productservice
      POSTGRES_PASSWORD: productpass
    volumes:
      - product_data:/var/lib/postgresql/data
    networks:
      - product-network

  order-db:
    image: postgres:13
    environment:
      POSTGRES_DB: orders
      POSTGRES_USER: orderservice
      POSTGRES_PASSWORD: orderpass
    volumes:
      - order_data:/var/lib/postgresql/data
    networks:
      - order-network

  # Shared Services
  redis:
    image: redis:alpine
    networks:
      - user-network
      - product-network

  rabbitmq:
    image: rabbitmq:3-management
    environment:
      RABBITMQ_DEFAULT_USER: admin
      RABBITMQ_DEFAULT_PASS: admin
    networks:
      - order-network

volumes:
  user_data:
  product_data:
  order_data:

networks:
  gateway-network:
  user-network:
  product-network:
  order-network:
```

## Best Practices for Complex Applications

### 1. Health Checks

```yaml
services:
  api:
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:3000/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s
```

### 2. Graceful Shutdown

```javascript
// In your Node.js application
process.on('SIGTERM', () => {
  console.log('SIGTERM received, shutting down gracefully');
  server.close(() => {
    console.log('Process terminated');
  });
});
```

### 3. Configuration Management

```yaml
services:
  app:
    env_file:
      - .env.common
      - .env.${ENVIRONMENT:-development}
    environment:
      - NODE_ENV=${ENVIRONMENT:-development}
```

### 4. Security Considerations

```yaml
services:
  database:
    image: postgres:13
    environment:
      POSTGRES_PASSWORD_FILE: /run/secrets/db_password
    secrets:
      - db_password
    networks:
      - backend  # Not exposed to frontend network

secrets:
  db_password:
    external: true
```

## Summary

In this lesson, you learned:
- Multi-service architecture patterns
- Building complex applications with Docker Compose
- Service communication strategies
- Advanced configuration techniques
- Microservices implementation
- Security and monitoring considerations

## Next Steps
- Practice building your own multi-service applications
- Experiment with different architecture patterns
- Move on to Lesson 3: Scaling and Load Balancing

## Additional Resources
- [Microservices Architecture Patterns](https://microservices.io/patterns/)
- [Docker Compose Production Guide](https://docs.docker.com/compose/production/)
- [Container Security Best Practices](https://docs.docker.com/engine/security/)
- [Service Mesh Patterns](https://servicemesh.io/)
