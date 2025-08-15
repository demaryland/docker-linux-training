# 🎯 Final Project: Complete Web Service Stack

*"Putting it all together - from Ubuntu basics to production containers"*

Congratulations! You've made it to the final project. This is where you'll demonstrate everything you've learned by deploying a complete, production-ready web service stack using Docker on Ubuntu Linux. You'll also see how the same concepts apply to RHEL-based systems.

## 🎯 Project Overview

You'll build and deploy a complete web application stack that includes:
- **Load Balancer** (Nginx) - Routes traffic to multiple app instances
- **Web Application** (Node.js) - A simple but functional web service
- **Database** (PostgreSQL) - Persistent data storage
- **Monitoring** (Prometheus + Grafana) - System and application metrics
- **Logging** (ELK Stack) - Centralized log management

This project simulates a real-world production deployment that you might encounter in both Ubuntu and RHEL environments.

## 🏗️ Architecture Overview

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Load Balancer │───▶│  Web App (x3)   │───▶│    Database     │
│     (Nginx)     │    │    (Node.js)    │    │  (PostgreSQL)   │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         ▼                       ▼                       ▼
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Monitoring    │    │     Logging     │    │   Persistent    │
│ (Prometheus +   │    │   (ELK Stack)   │    │    Storage      │
│   Grafana)      │    │                 │    │   (Volumes)     │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

## 📋 Project Requirements

### Core Requirements (Must Complete)
- [ ] Deploy load balancer with Nginx
- [ ] Run 3 instances of the web application
- [ ] Set up PostgreSQL database with persistent storage
- [ ] Configure container networking
- [ ] Implement health checks
- [ ] Use Docker Compose for orchestration

### Advanced Requirements (Bonus Points)
- [ ] Add monitoring with Prometheus and Grafana
- [ ] Implement centralized logging
- [ ] Set up automated backups
- [ ] Configure SSL/TLS certificates
- [ ] Implement rolling updates
- [ ] Add container resource limits

### Documentation Requirements
- [ ] Document your architecture decisions
- [ ] Create deployment instructions
- [ ] Include troubleshooting guide
- [ ] Compare Ubuntu vs RHEL deployment considerations

## 🚀 Getting Started

### Step 1: Project Structure

Create the following directory structure:

```
final-project/
├── docker-compose.yml          # Main orchestration file
├── nginx/
│   ├── Dockerfile              # Custom nginx configuration
│   └── nginx.conf              # Load balancer configuration
├── webapp/
│   ├── Dockerfile              # Web application image
│   ├── package.json            # Node.js dependencies
│   ├── server.js               # Application code
│   └── src/                    # Application source code
├── database/
│   ├── init.sql                # Database initialization
│   └── backup/                 # Backup scripts
├── monitoring/
│   ├── prometheus.yml          # Metrics configuration
│   └── grafana/                # Dashboard configurations
├── logging/
│   └── logstash.conf           # Log processing configuration
└── docs/
    ├── deployment.md           # Deployment instructions
    ├── architecture.md         # Architecture documentation
    └── troubleshooting.md      # Common issues and solutions
```

### Step 2: Environment Setup

1. **Verify your Ubuntu environment:**
   ```bash
   docker --version
   docker-compose --version
   uname -a
   ```

2. **Create project directory:**
   ```bash
   mkdir -p ~/final-project
   cd ~/final-project
   ```

3. **Initialize Git repository:**
   ```bash
   git init
   echo "node_modules/" > .gitignore
   echo "*.log" >> .gitignore
   ```

## 🐳 Implementation Guide

### Phase 1: Basic Web Application

#### 1.1 Create the Web Application

**File: `webapp/package.json`**
```json
{
  "name": "docker-learning-webapp",
  "version": "1.0.0",
  "description": "Final project web application",
  "main": "server.js",
  "scripts": {
    "start": "node server.js",
    "dev": "nodemon server.js"
  },
  "dependencies": {
    "express": "^4.18.0",
    "pg": "^8.8.0",
    "winston": "^3.8.0"
  },
  "engines": {
    "node": ">=16"
  }
}
```

**File: `webapp/server.js`**
```javascript
const express = require('express');
const { Pool } = require('pg');
const winston = require('winston');

const app = express();
const port = process.env.PORT || 3000;

// Configure logging
const logger = winston.createLogger({
  level: 'info',
  format: winston.format.json(),
  transports: [
    new winston.transports.Console(),
    new winston.transports.File({ filename: 'app.log' })
  ]
});

// Database connection
const pool = new Pool({
  user: process.env.DB_USER || 'postgres',
  host: process.env.DB_HOST || 'database',
  database: process.env.DB_NAME || 'webapp',
  password: process.env.DB_PASSWORD || 'password',
  port: process.env.DB_PORT || 5432,
});

app.use(express.json());

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({ 
    status: 'healthy', 
    timestamp: new Date().toISOString(),
    instance: process.env.HOSTNAME || 'unknown'
  });
});

// Main application endpoint
app.get('/', async (req, res) => {
  try {
    const result = await pool.query('SELECT NOW() as current_time');
    logger.info('Database query successful');
    
    res.json({
      message: 'Welcome to the Docker Learning Final Project!',
      instance: process.env.HOSTNAME || 'unknown',
      database_time: result.rows[0].current_time,
      platform: process.platform
    });
  } catch (error) {
    logger.error('Database connection failed', error);
    res.status(500).json({ error: 'Database connection failed' });
  }
});

// Visitor counter endpoint
app.post('/visit', async (req, res) => {
  try {
    await pool.query('INSERT INTO visits (timestamp) VALUES (NOW())');
    const result = await pool.query('SELECT COUNT(*) as total FROM visits');
    
    logger.info('Visit recorded');
    res.json({ 
      message: 'Visit recorded',
      total_visits: result.rows[0].total 
    });
  } catch (error) {
    logger.error('Failed to record visit', error);
    res.status(500).json({ error: 'Failed to record visit' });
  }
});

app.listen(port, () => {
  logger.info(`Server running on port ${port}`);
});
```

**File: `webapp/Dockerfile`**
```dockerfile
# Use Ubuntu-based Node.js image
FROM node:18-bullseye-slim

# Set working directory
WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm ci --only=production

# Copy application code
COPY . .

# Create non-root user
RUN groupadd -r appuser && useradd -r -g appuser appuser
RUN chown -R appuser:appuser /app
USER appuser

# Expose port
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:3000/health || exit 1

# Start application
CMD ["npm", "start"]
```

#### 1.2 Create the Load Balancer

**File: `nginx/nginx.conf`**
```nginx
events {
    worker_connections 1024;
}

http {
    upstream webapp {
        server webapp1:3000;
        server webapp2:3000;
        server webapp3:3000;
    }

    server {
        listen 80;
        
        location / {
            proxy_pass http://webapp;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }

        location /health {
            access_log off;
            return 200 "healthy\n";
            add_header Content-Type text/plain;
        }
    }
}
```

**File: `nginx/Dockerfile`**
```dockerfile
FROM nginx:alpine

# Copy custom configuration
COPY nginx.conf /etc/nginx/nginx.conf

# Add health check
RUN apk add --no-cache curl

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost/health || exit 1

EXPOSE 80
```

#### 1.3 Database Setup

**File: `database/init.sql`**
```sql
-- Create visits table
CREATE TABLE IF NOT EXISTS visits (
    id SERIAL PRIMARY KEY,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insert sample data
INSERT INTO visits (timestamp) VALUES 
    (NOW() - INTERVAL '1 day'),
    (NOW() - INTERVAL '2 hours'),
    (NOW() - INTERVAL '30 minutes');

-- Create index for performance
CREATE INDEX IF NOT EXISTS idx_visits_timestamp ON visits(timestamp);
```

### Phase 2: Docker Compose Orchestration

**File: `docker-compose.yml`**
```yaml
version: '3.8'

services:
  # Load Balancer
  nginx:
    build: ./nginx
    ports:
      - "8080:80"
    depends_on:
      - webapp1
      - webapp2
      - webapp3
    networks:
      - frontend
    restart: unless-stopped

  # Web Application Instances
  webapp1:
    build: ./webapp
    environment:
      - DB_HOST=database
      - DB_USER=postgres
      - DB_PASSWORD=password
      - DB_NAME=webapp
      - PORT=3000
    depends_on:
      - database
    networks:
      - frontend
      - backend
    restart: unless-stopped

  webapp2:
    build: ./webapp
    environment:
      - DB_HOST=database
      - DB_USER=postgres
      - DB_PASSWORD=password
      - DB_NAME=webapp
      - PORT=3000
    depends_on:
      - database
    networks:
      - frontend
      - backend
    restart: unless-stopped

  webapp3:
    build: ./webapp
    environment:
      - DB_HOST=database
      - DB_USER=postgres
      - DB_PASSWORD=password
      - DB_NAME=webapp
      - PORT=3000
    depends_on:
      - database
    networks:
      - frontend
      - backend
    restart: unless-stopped

  # Database
  database:
    image: postgres:15-alpine
    environment:
      - POSTGRES_DB=webapp
      - POSTGRES_USER=postgres
      - POSTGRES_PASSWORD=password
    volumes:
      - postgres_data:/var/lib/postgresql/data
      - ./database/init.sql:/docker-entrypoint-initdb.d/init.sql
    networks:
      - backend
    restart: unless-stopped
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres"]
      interval: 30s
      timeout: 10s
      retries: 3

  # Monitoring (Bonus)
  prometheus:
    image: prom/prometheus:latest
    ports:
      - "9090:9090"
    volumes:
      - ./monitoring/prometheus.yml:/etc/prometheus/prometheus.yml
    networks:
      - monitoring
    restart: unless-stopped

  grafana:
    image: grafana/grafana:latest
    ports:
      - "3001:3000"
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=admin
    volumes:
      - grafana_data:/var/lib/grafana
    networks:
      - monitoring
    restart: unless-stopped

networks:
  frontend:
    driver: bridge
  backend:
    driver: bridge
  monitoring:
    driver: bridge

volumes:
  postgres_data:
  grafana_data:
```

### Phase 3: Deployment and Testing

#### 3.1 Deploy the Stack

```bash
# Build and start all services
docker-compose up -d

# Check service status
docker-compose ps

# View logs
docker-compose logs -f webapp1
```

#### 3.2 Test the Application

```bash
# Test load balancer
curl http://localhost:8080

# Test health endpoints
curl http://localhost:8080/health

# Test database connectivity
curl -X POST http://localhost:8080/visit

# Check multiple instances are responding
for i in {1..10}; do
  curl -s http://localhost:8080 | jq .instance
done
```

#### 3.3 Monitor the System

```bash
# Check container resource usage
docker stats

# View container logs
docker-compose logs webapp1

# Check database
docker-compose exec database psql -U postgres -d webapp -c "SELECT * FROM visits;"
```

## 🔄 Ubuntu vs RHEL Deployment Considerations

### Ubuntu Deployment
```bash
# Ubuntu-specific commands
sudo apt update && sudo apt install docker.io docker-compose
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker $USER

# Deploy application
docker-compose up -d
```

### RHEL Deployment
```bash
# RHEL-specific commands
sudo dnf install docker-ce docker-compose-plugin
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker $USER

# Deploy application (same Docker Compose file!)
docker compose up -d  # Note: newer syntax
```

### Key Differences
- **Package installation**: `apt` vs `dnf`
- **Docker Compose**: Ubuntu uses `docker-compose`, RHEL uses `docker compose`
- **SELinux**: RHEL requires SELinux considerations
- **Firewall**: Ubuntu uses UFW, RHEL uses firewalld
- **Base images**: Can use Ubuntu or RHEL UBI base images

### Platform-Agnostic Benefits
- **Same Docker commands**: Container operations identical
- **Same Compose file**: Application definition portable
- **Same networking**: Docker networking works identically
- **Same volumes**: Data persistence works the same

## 📊 Success Criteria

### Functional Requirements
- [ ] All services start successfully
- [ ] Load balancer distributes traffic across 3 app instances
- [ ] Database stores and retrieves data correctly
- [ ] Health checks pass for all services
- [ ] Application handles concurrent requests

### Performance Requirements
- [ ] Application responds within 500ms
- [ ] System handles 100 concurrent requests
- [ ] Database queries complete within 100ms
- [ ] No memory leaks after 1 hour of operation

### Operational Requirements
- [ ] Services restart automatically on failure
- [ ] Logs are accessible and meaningful
- [ ] Monitoring shows system metrics
- [ ] Backup and restore procedures work
- [ ] Documentation is complete and accurate

## 🎓 Learning Outcomes

By completing this project, you will have demonstrated:

### Technical Skills
- **Container orchestration** with Docker Compose
- **Multi-service architecture** design and implementation
- **Load balancing** and high availability concepts
- **Database integration** with persistent storage
- **Monitoring and logging** best practices
- **Ubuntu Linux** system administration

### Professional Skills
- **System architecture** documentation
- **Deployment automation** with Infrastructure as Code
- **Troubleshooting** complex multi-container applications
- **Cross-platform awareness** (Ubuntu vs RHEL)
- **Production readiness** considerations

### Industry Readiness
- **Real-world application** of containerization
- **Enterprise deployment** patterns
- **DevOps practices** and methodologies
- **Platform flexibility** and portability
- **Scalability** and reliability concepts

## 🚀 Next Steps

After completing this project, consider:

1. **Deploy to cloud platforms** (AWS, Azure, GCP)
2. **Learn Kubernetes** for container orchestration at scale
3. **Implement CI/CD pipelines** for automated deployment
4. **Add security scanning** and vulnerability management
5. **Explore service mesh** technologies like Istio
6. **Study site reliability engineering** practices

## 🏆 Congratulations!

You've successfully completed the Docker & Ubuntu Linux Learning Journey! You now have:

- **Solid Ubuntu Linux skills** with RHEL awareness
- **Production-ready Docker expertise**
- **Multi-container application experience**
- **Real-world deployment knowledge**
- **Cross-platform adaptability**

You're ready to tackle containerization challenges in any Linux environment!

---

*"The expert in anything was once a beginner."* - You've made the journey from beginner to container expert! 🎉🐳

### 🌟 Share Your Success

- Update your LinkedIn with new container skills
- Share your project on GitHub
- Write a blog post about your learning journey
- Help others learn containers and Linux
- Continue building amazing containerized applications!

**Welcome to the container community!** 🚀
