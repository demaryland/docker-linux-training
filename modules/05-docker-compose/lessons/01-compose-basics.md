# Lesson 1: Introduction to Docker Compose

## Learning Objectives
By the end of this lesson, you will be able to:
- Understand Docker Compose concepts and benefits
- Write basic YAML syntax for Compose files
- Create your first docker-compose.yml file
- Convert manual Docker commands to Compose configuration
- Manage multi-container applications with simple commands

## Prerequisites
- Completed Docker Fundamentals module
- Understanding of Docker containers and images
- Basic knowledge of YAML syntax (we'll cover this)

## What is Docker Compose?

Docker Compose is a tool for defining and running multi-container Docker applications. Instead of managing containers individually with multiple `docker run` commands, you define your entire application stack in a single YAML file.

### Key Benefits

1. **Simplified Management**: One command to start/stop entire applications
2. **Declarative Configuration**: Define what you want, not how to get there
3. **Environment Consistency**: Same configuration across dev, test, and production
4. **Service Dependencies**: Automatic handling of startup order
5. **Network Isolation**: Automatic network creation and service discovery
6. **Volume Management**: Persistent data handling made easy

### When to Use Docker Compose

- **Development environments** with multiple services
- **Testing scenarios** requiring dependent services
- **Single-host deployments** for production
- **Prototyping** complex application architectures
- **CI/CD pipelines** for integration testing

## YAML Syntax Fundamentals

Docker Compose uses YAML (YAML Ain't Markup Language) for configuration. Let's cover the basics:

### Basic YAML Rules

```yaml
# Comments start with hash
key: value                    # String value
number: 42                    # Number value
boolean: true                 # Boolean value
list:                        # List/Array
  - item1
  - item2
  - item3

nested:                      # Nested object
  key1: value1
  key2: value2

# Indentation matters! Use spaces, not tabs
# 2 spaces is the standard indentation
```

### Docker Compose YAML Structure

```yaml
version: '3.8'              # Compose file version

services:                   # Define your containers
  service1:
    image: nginx:alpine
    ports:
      - "80:80"
  
  service2:
    build: ./app
    environment:
      - NODE_ENV=development

volumes:                    # Define persistent storage
  data_volume:

networks:                   # Define custom networks
  app_network:
```

## Your First Docker Compose File

Let's start with a simple example - a web server with a database.

### Step 1: Create Project Structure

```bash
# Create project directory
mkdir my-first-compose
cd my-first-compose

# Create application files
mkdir html
echo "<h1>Hello from Docker Compose!</h1>" > html/index.html
```

### Step 2: Create docker-compose.yml

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
      - db

  db:
    image: postgres:13
    environment:
      POSTGRES_DB: myapp
      POSTGRES_USER: user
      POSTGRES_PASSWORD: password
    volumes:
      - db_data:/var/lib/postgresql/data

volumes:
  db_data:
```

### Step 3: Run Your Application

```bash
# Start all services
docker-compose up

# Or run in background
docker-compose up -d

# Check status
docker-compose ps

# View logs
docker-compose logs

# Stop everything
docker-compose down
```

## Hands-on Lab 1: Converting Manual Commands

Let's take a complex manual setup and convert it to Docker Compose.

### Manual Approach (Don't run this - just for comparison)

```bash
# Create network
docker network create blog-network

# Start database
docker run -d \
  --name blog-db \
  --network blog-network \
  -e MYSQL_ROOT_PASSWORD=rootpass \
  -e MYSQL_DATABASE=blog \
  -e MYSQL_USER=blogger \
  -e MYSQL_PASSWORD=blogpass \
  -v blog_db_data:/var/lib/mysql \
  mysql:8.0

# Start Redis cache
docker run -d \
  --name blog-cache \
  --network blog-network \
  redis:alpine

# Start WordPress
docker run -d \
  --name blog-app \
  --network blog-network \
  -p 8080:80 \
  -e WORDPRESS_DB_HOST=blog-db \
  -e WORDPRESS_DB_NAME=blog \
  -e WORDPRESS_DB_USER=blogger \
  -e WORDPRESS_DB_PASSWORD=blogpass \
  -v blog_content:/var/www/html \
  wordpress:latest

# Start phpMyAdmin
docker run -d \
  --name blog-admin \
  --network blog-network \
  -p 8081:80 \
  -e PMA_HOST=blog-db \
  -e PMA_USER=root \
  -e PMA_PASSWORD=rootpass \
  phpmyadmin:latest
```

### Compose Approach

Create `docker-compose.yml`:

```yaml
version: '3.8'

services:
  db:
    image: mysql:8.0
    environment:
      MYSQL_ROOT_PASSWORD: rootpass
      MYSQL_DATABASE: blog
      MYSQL_USER: blogger
      MYSQL_PASSWORD: blogpass
    volumes:
      - blog_db_data:/var/lib/mysql
    networks:
      - blog-network

  cache:
    image: redis:alpine
    networks:
      - blog-network

  wordpress:
    image: wordpress:latest
    ports:
      - "8080:80"
    environment:
      WORDPRESS_DB_HOST: db
      WORDPRESS_DB_NAME: blog
      WORDPRESS_DB_USER: blogger
      WORDPRESS_DB_PASSWORD: blogpass
    volumes:
      - blog_content:/var/www/html
    depends_on:
      - db
      - cache
    networks:
      - blog-network

  phpmyadmin:
    image: phpmyadmin:latest
    ports:
      - "8081:80"
    environment:
      PMA_HOST: db
      PMA_USER: root
      PMA_PASSWORD: rootpass
    depends_on:
      - db
    networks:
      - blog-network

volumes:
  blog_db_data:
  blog_content:

networks:
  blog-network:
```

### Run the Blog Platform

```bash
# Start everything
docker-compose up -d

# Check status
docker-compose ps

# View logs for specific service
docker-compose logs wordpress

# Access the applications
# WordPress: http://localhost:8080
# phpMyAdmin: http://localhost:8081
```

## Essential Docker Compose Commands

### Application Lifecycle

```bash
# Start services
docker-compose up                    # Foreground
docker-compose up -d                 # Background (detached)
docker-compose up --build            # Build images first

# Stop services
docker-compose stop                  # Stop containers
docker-compose down                  # Stop and remove containers
docker-compose down -v               # Also remove volumes
docker-compose down --rmi all        # Also remove images

# Restart services
docker-compose restart               # Restart all services
docker-compose restart service_name  # Restart specific service
```

### Service Management

```bash
# View status
docker-compose ps                    # List services
docker-compose top                   # Show running processes

# View logs
docker-compose logs                  # All services
docker-compose logs service_name     # Specific service
docker-compose logs -f service_name  # Follow logs

# Execute commands
docker-compose exec service_name bash    # Interactive shell
docker-compose exec service_name ls -la  # Run command
docker-compose run service_name command  # Run one-off command
```

### Building and Updating

```bash
# Build services
docker-compose build                 # Build all services
docker-compose build service_name    # Build specific service

# Pull images
docker-compose pull                  # Pull all images
docker-compose pull service_name     # Pull specific image

# Scale services
docker-compose up -d --scale web=3   # Run 3 instances of web service
```

## Hands-on Lab 2: Development Environment

Let's create a complete development environment for a Node.js application.

### Step 1: Create Project Structure

```bash
mkdir node-dev-env
cd node-dev-env
mkdir app
```

### Step 2: Create Application Files

Create `app/package.json`:

```json
{
  "name": "dev-app",
  "version": "1.0.0",
  "main": "server.js",
  "scripts": {
    "start": "node server.js",
    "dev": "nodemon server.js"
  },
  "dependencies": {
    "express": "^4.18.0",
    "redis": "^4.3.0",
    "pg": "^8.8.0"
  },
  "devDependencies": {
    "nodemon": "^2.0.20"
  }
}
```

Create `app/server.js`:

```javascript
const express = require('express');
const redis = require('redis');
const { Client } = require('pg');

const app = express();
const port = 3000;

// Redis client
const redisClient = redis.createClient({
  host: 'cache',
  port: 6379
});

// PostgreSQL client
const pgClient = new Client({
  host: 'database',
  port: 5432,
  database: 'devapp',
  user: 'developer',
  password: 'devpass'
});

app.get('/', (req, res) => {
  res.json({
    message: 'Development Environment Running!',
    timestamp: new Date().toISOString(),
    environment: process.env.NODE_ENV || 'development'
  });
});

app.get('/health', async (req, res) => {
  try {
    // Test database connection
    await pgClient.query('SELECT NOW()');
    
    // Test Redis connection
    await redisClient.ping();
    
    res.json({ status: 'healthy', services: ['database', 'cache'] });
  } catch (error) {
    res.status(500).json({ status: 'unhealthy', error: error.message });
  }
});

app.listen(port, () => {
  console.log(`Development server running on port ${port}`);
});

// Initialize connections
pgClient.connect().catch(console.error);
redisClient.connect().catch(console.error);
```

### Step 3: Create Dockerfile for Development

Create `app/Dockerfile.dev`:

```dockerfile
FROM node:16-alpine

WORKDIR /app

# Install dependencies
COPY package*.json ./
RUN npm install

# Copy source code
COPY . .

# Expose port
EXPOSE 3000

# Start with nodemon for development
CMD ["npm", "run", "dev"]
```

### Step 4: Create Docker Compose Configuration

Create `docker-compose.yml`:

```yaml
version: '3.8'

services:
  app:
    build:
      context: ./app
      dockerfile: Dockerfile.dev
    ports:
      - "3000:3000"
    volumes:
      - ./app:/app
      - /app/node_modules
    environment:
      - NODE_ENV=development
      - DATABASE_URL=postgresql://developer:devpass@database:5432/devapp
      - REDIS_URL=redis://cache:6379
    depends_on:
      - database
      - cache
    networks:
      - dev-network

  database:
    image: postgres:13
    environment:
      POSTGRES_DB: devapp
      POSTGRES_USER: developer
      POSTGRES_PASSWORD: devpass
    volumes:
      - postgres_data:/var/lib/postgresql/data
      - ./init.sql:/docker-entrypoint-initdb.d/init.sql
    ports:
      - "5432:5432"
    networks:
      - dev-network

  cache:
    image: redis:alpine
    ports:
      - "6379:6379"
    networks:
      - dev-network

  adminer:
    image: adminer:latest
    ports:
      - "8080:8080"
    depends_on:
      - database
    networks:
      - dev-network

volumes:
  postgres_data:

networks:
  dev-network:
```

### Step 5: Create Database Initialization

Create `init.sql`:

```sql
-- Create a sample table
CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insert sample data
INSERT INTO users (name, email) VALUES 
    ('John Doe', 'john@example.com'),
    ('Jane Smith', 'jane@example.com');
```

### Step 6: Start Development Environment

```bash
# Start all services
docker-compose up -d

# Check status
docker-compose ps

# View application logs
docker-compose logs -f app

# Test the application
curl http://localhost:3000
curl http://localhost:3000/health

# Access database admin: http://localhost:8080
# Server: database, Username: developer, Password: devpass
```

## Service Dependencies and Startup Order

### Understanding depends_on

```yaml
services:
  web:
    image: nginx
    depends_on:
      - api
      - cache

  api:
    image: myapp/api
    depends_on:
      - database

  database:
    image: postgres
  
  cache:
    image: redis
```

**Important**: `depends_on` only controls startup order, not readiness. The dependent service might start before the dependency is fully ready.

### Health Checks for Better Dependencies

```yaml
services:
  database:
    image: postgres:13
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 60s

  api:
    image: myapp/api
    depends_on:
      database:
        condition: service_healthy
```

## Environment Variables and Configuration

### Using Environment Variables

```yaml
services:
  app:
    image: myapp
    environment:
      - NODE_ENV=production
      - DATABASE_URL=postgresql://user:pass@db:5432/myapp
      - API_KEY=${API_KEY}  # From host environment
```

### Environment Files

Create `.env` file:

```bash
NODE_ENV=development
DATABASE_URL=postgresql://dev:devpass@localhost:5432/devdb
API_KEY=your-secret-key
REDIS_URL=redis://localhost:6379
```

Reference in compose file:

```yaml
services:
  app:
    image: myapp
    env_file:
      - .env
    environment:
      - NODE_ENV=production  # Overrides .env value
```

## Common Patterns and Best Practices

### 1. Service Naming

```yaml
# Good: Descriptive names
services:
  web-frontend:
    image: nginx
  
  api-backend:
    image: myapp/api
  
  user-database:
    image: postgres

# Avoid: Generic names like app, db, service1
```

### 2. Port Management

```yaml
services:
  web:
    ports:
      - "8080:80"      # host:container
      - "127.0.0.1:8081:81"  # bind to specific interface
  
  api:
    expose:
      - "3000"         # Only accessible to other services
```

### 3. Volume Patterns

```yaml
services:
  app:
    volumes:
      - ./src:/app/src           # Bind mount for development
      - app_data:/app/data       # Named volume for persistence
      - /app/node_modules        # Anonymous volume to preserve
```

## Troubleshooting Common Issues

### 1. Service Won't Start

```bash
# Check logs
docker-compose logs service_name

# Check configuration
docker-compose config

# Validate YAML syntax
docker-compose config --quiet
```

### 2. Port Conflicts

```bash
# Error: Port already in use
# Solution: Change port mapping or stop conflicting service
docker-compose ps
netstat -tulpn | grep :8080
```

### 3. Volume Permission Issues

```bash
# Check volume mounts
docker-compose exec service_name ls -la /mounted/path

# Fix permissions
docker-compose exec service_name chown -R user:group /path
```

### 4. Network Connectivity

```bash
# Test service connectivity
docker-compose exec service1 ping service2
docker-compose exec service1 nc -zv service2 port
```

## Summary

In this lesson, you learned:
- Docker Compose fundamentals and benefits
- YAML syntax for Compose files
- Converting manual Docker commands to Compose
- Essential Compose commands and workflows
- Service dependencies and configuration
- Common patterns and troubleshooting

## Next Steps
- Practice creating Compose files for different scenarios
- Experiment with different service configurations
- Move on to Lesson 2: Building Complex Applications

## Additional Resources
- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [Compose File Reference](https://docs.docker.com/compose/compose-file/)
- [YAML Syntax Guide](https://yaml.org/spec/1.2/spec.html)
- [Docker Compose Best Practices](https://docs.docker.com/develop/dev-best-practices/)
