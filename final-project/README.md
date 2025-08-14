# 🎯 Final Project: Deploy Your Own Web Service Stack

*"Putting it all together - from Linux novice to container expert!"*

Congratulations on making it to the final project! This is where you'll demonstrate everything you've learned by deploying a complete, real-world web application stack using Docker containers on Rocky Linux 9.

## 🎯 Project Overview

You'll deploy a **complete web service stack** that includes:
- **Load Balancer** (nginx)
- **Web Application** (a simple web app)
- **Database** (MySQL or PostgreSQL)
- **Monitoring** (basic health checks)
- **Persistent Storage** (for database data)
- **Custom Networking** (container communication)

This project simulates a real production deployment and will test your skills across all modules.

## 🏆 Learning Objectives

By completing this project, you'll demonstrate:
- Linux command proficiency
- Docker container management
- Custom image building
- Multi-container orchestration
- Network configuration
- Volume management
- Production-ready practices
- Troubleshooting skills

## 📋 Project Requirements

### Functional Requirements
1. **Web Application**: Deploy a working web application accessible from a browser
2. **Database Integration**: Web app must connect to and use a database
3. **Load Balancing**: Multiple web app instances behind a load balancer
4. **Persistence**: Database data must survive container restarts
5. **Health Monitoring**: Basic health checks for all services
6. **Custom Configuration**: Use environment variables for configuration

### Technical Requirements
1. **Use Docker Compose** for orchestration
2. **Custom Docker images** for the web application
3. **Named volumes** for database persistence
4. **Custom network** for service communication
5. **Port mapping** for external access
6. **Environment variables** for configuration
7. **Resource limits** for production readiness

## 🚀 Project Phases

### Phase 1: Planning and Setup (30 minutes)
1. **Review the requirements** and plan your architecture
2. **Set up your project directory** structure
3. **Choose your technology stack** (we'll provide options)
4. **Create your project documentation**

### Phase 2: Database Layer (45 minutes)
1. **Deploy database container** with persistent storage
2. **Configure database** with initial schema
3. **Test database connectivity** and data persistence
4. **Document database setup**

### Phase 3: Web Application Layer (60 minutes)
1. **Create a simple web application** (or use provided template)
2. **Build custom Docker image** for the web app
3. **Configure database connection** using environment variables
4. **Test web application** functionality

### Phase 4: Load Balancer Layer (30 minutes)
1. **Configure nginx** as a load balancer
2. **Set up multiple web app instances**
3. **Test load balancing** functionality
4. **Configure health checks**

### Phase 5: Integration and Testing (45 minutes)
1. **Create Docker Compose file** for the entire stack
2. **Configure networking** between services
3. **Test the complete stack** end-to-end
4. **Verify persistence** and failover scenarios

### Phase 6: Production Hardening (30 minutes)
1. **Add resource limits** to containers
2. **Implement security best practices**
3. **Add monitoring and logging**
4. **Create deployment documentation**

## 🛠️ Technology Stack Options

Choose one of these stacks based on your comfort level:

### Option A: Simple Stack (Recommended for beginners)
- **Web App**: Static HTML/CSS/JavaScript with simple API
- **Database**: MySQL 8.0
- **Load Balancer**: nginx
- **Language**: JavaScript (Node.js) or Python (Flask)

### Option B: Intermediate Stack
- **Web App**: Dynamic web application with CRUD operations
- **Database**: PostgreSQL 13
- **Load Balancer**: nginx with advanced configuration
- **Language**: Python (Django/Flask) or Node.js (Express)

### Option C: Advanced Stack (For experienced participants)
- **Web App**: Full-featured web application
- **Database**: PostgreSQL with Redis cache
- **Load Balancer**: nginx with SSL termination
- **Monitoring**: Prometheus and Grafana
- **Language**: Your choice

## 📁 Project Structure

Create this directory structure for your project:

```
final-project/
├── README.md                    # Your project documentation
├── docker-compose.yml           # Main orchestration file
├── .env                        # Environment variables
├── nginx/
│   ├── Dockerfile              # Custom nginx configuration
│   └── nginx.conf              # Load balancer configuration
├── webapp/
│   ├── Dockerfile              # Web application image
│   ├── src/                    # Application source code
│   └── requirements.txt        # Dependencies (if applicable)
├── database/
│   ├── init.sql               # Database initialization
│   └── backup/                # Database backups
├── monitoring/
│   └── health-check.sh        # Health check scripts
└── docs/
    ├── deployment.md          # Deployment instructions
    ├── architecture.md        # System architecture
    └── troubleshooting.md     # Common issues and solutions
```

## 🧪 Provided Resources

### Sample Web Application (Node.js)
```javascript
// webapp/src/app.js
const express = require('express');
const mysql = require('mysql2');
const app = express();

const db = mysql.createConnection({
  host: process.env.DB_HOST || 'database',
  user: process.env.DB_USER || 'root',
  password: process.env.DB_PASSWORD || 'password',
  database: process.env.DB_NAME || 'webapp'
});

app.get('/', (req, res) => {
  res.send(`
    <h1>Welcome to Your Web Service Stack!</h1>
    <p>Server: ${process.env.HOSTNAME}</p>
    <p>Database Status: Connected</p>
    <a href="/health">Health Check</a>
  `);
});

app.get('/health', (req, res) => {
  db.ping((err) => {
    if (err) {
      res.status(500).json({ status: 'unhealthy', database: 'disconnected' });
    } else {
      res.json({ status: 'healthy', database: 'connected' });
    }
  });
});

app.listen(3000, () => {
  console.log('Web app running on port 3000');
});
```

### Sample Docker Compose Template
```yaml
version: '3.8'

services:
  database:
    image: mysql:8.0
    environment:
      MYSQL_ROOT_PASSWORD: ${DB_ROOT_PASSWORD}
      MYSQL_DATABASE: ${DB_NAME}
    volumes:
      - db_data:/var/lib/mysql
      - ./database/init.sql:/docker-entrypoint-initdb.d/init.sql
    networks:
      - backend
    restart: unless-stopped

  webapp:
    build: ./webapp
    environment:
      DB_HOST: database
      DB_USER: root
      DB_PASSWORD: ${DB_ROOT_PASSWORD}
      DB_NAME: ${DB_NAME}
    depends_on:
      - database
    networks:
      - backend
    restart: unless-stopped
    deploy:
      replicas: 2

  loadbalancer:
    build: ./nginx
    ports:
      - "80:80"
    depends_on:
      - webapp
    networks:
      - backend
    restart: unless-stopped

volumes:
  db_data:

networks:
  backend:
    driver: bridge
```

## ✅ Testing Checklist

Before submitting your project, verify:

### Basic Functionality
- [ ] Web application loads in browser
- [ ] Database connection works
- [ ] Load balancer distributes requests
- [ ] Health checks return correct status

### Persistence Testing
- [ ] Stop and restart database container
- [ ] Verify data persists after restart
- [ ] Test volume mounting

### Scaling Testing
- [ ] Scale web app instances up and down
- [ ] Verify load balancer adapts
- [ ] Test failover scenarios

### Network Testing
- [ ] Services can communicate internally
- [ ] External access works correctly
- [ ] Port mappings are correct

### Production Readiness
- [ ] Resource limits are set
- [ ] Restart policies configured
- [ ] Environment variables used
- [ ] Security practices implemented

## 🎯 Evaluation Criteria

Your project will be evaluated on:

### Technical Implementation (40%)
- Correct Docker and Docker Compose usage
- Proper networking and volume configuration
- Working multi-container application
- Custom image creation

### Best Practices (30%)
- Security considerations
- Resource management
- Configuration management
- Error handling

### Documentation (20%)
- Clear setup instructions
- Architecture explanation
- Troubleshooting guide
- Code comments

### Presentation (10%)
- Demonstration of working system
- Explanation of design decisions
- Discussion of challenges and solutions

## 🚀 Getting Started

1. **Create your project directory**:
   ```bash
   mkdir my-web-stack
   cd my-web-stack
   ```

2. **Copy the project template**:
   ```bash
   cp -r /workspaces/docker-rocky-learning/final-project/template/* .
   ```

3. **Start with the database**:
   ```bash
   # Create a simple docker-compose.yml with just the database
   # Test it works before adding other services
   ```

4. **Build incrementally**:
   - Get database working first
   - Add web application
   - Add load balancer
   - Add monitoring and hardening

## 🆘 Getting Help

- **Stuck on a concept?** Review the relevant module materials
- **Docker issues?** Check the troubleshooting guide
- **Need inspiration?** Look at the sample applications provided
- **Want to discuss?** Use this as an opportunity for peer learning

## 🏆 Bonus Challenges

For those who finish early or want extra credit:

### Monitoring Enhancement
- Add Prometheus metrics collection
- Create Grafana dashboards
- Implement alerting

### Security Hardening
- Implement SSL/TLS termination
- Add authentication to web app
- Use Docker secrets for passwords

### Advanced Networking
- Implement service discovery
- Add API gateway functionality
- Create multiple environments (dev/staging/prod)

### CI/CD Integration
- Create GitHub Actions workflow
- Implement automated testing
- Add deployment automation

## 📝 Submission Requirements

Submit your project with:

1. **Complete source code** in your project directory
2. **README.md** with setup and usage instructions
3. **Architecture diagram** (can be simple text-based)
4. **Demonstration video** (5-10 minutes) showing:
   - Deployment process
   - Working application
   - Key features and testing

## 🎉 Completion

Once you've completed this project, you'll have:
- Built a production-ready containerized application stack
- Demonstrated proficiency with Docker and Linux
- Created something you can showcase in your portfolio
- Gained confidence to tackle real-world container deployments

**Congratulations on your journey from Windows IT professional to Linux container expert!** 🐳🎓

---

*"The best way to learn is by doing. This project is your opportunity to prove to yourself that you've mastered these technologies."* - Now go build something amazing! 🚀
