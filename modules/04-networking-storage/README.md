# 🌐 Module 4: Connecting the Dots - Networking and Storage

*"Making containers talk to each other and remember things"*

Welcome to the infrastructure side of containers! You've learned to run containers and build images - now let's make them work together as a cohesive system. This module covers the essential skills for building multi-container applications that can communicate and persist data.

## 🎯 Learning Objectives

By the end of this module, you'll be able to:
- Create and manage Docker networks for container communication
- Implement persistent storage with volumes and bind mounts
- Configure environment variables for application settings
- Connect containers securely and efficiently
- Troubleshoot networking and storage issues
- Design resilient multi-container architectures

## 📚 Module Contents

### 🌐 [Lesson 1: Container Networking Fundamentals](lessons/01-networking-fundamentals.md)
*"How containers talk to each other"*
- Docker networking concepts
- Bridge, host, and custom networks
- Container name resolution
- **Lab**: Connect multiple containers

### 🔌 [Lesson 2: Advanced Networking Scenarios](lessons/02-advanced-networking.md)
*"Complex networking for real applications"*
- Port mapping strategies
- Network isolation and security
- Load balancing basics
- **Lab**: Build a multi-tier application network

### 💾 [Lesson 3: Data Persistence with Volumes](lessons/03-volumes-storage.md)
*"Making sure your data survives"*
- Understanding container data lifecycle
- Named volumes vs bind mounts
- Volume management and backup
- **Lab**: Implement persistent database storage

### ⚙️ [Lesson 4: Configuration Management](lessons/04-configuration-management.md)
*"Configuring containers for different environments"*
- Environment variables and secrets
- Configuration files and templates
- Multi-environment deployments
- **Lab**: Configure applications for dev/staging/prod

### 🔧 [Lesson 5: Troubleshooting Networks and Storage](lessons/05-troubleshooting.md)
*"When things don't connect or persist"*
- Network debugging techniques
- Storage troubleshooting
- Performance optimization
- **Lab**: Debug and fix broken container communications

## 🎮 Module Challenge: "The Microservices Communication Hub"

Build a complete microservices application with:
- Frontend web application
- Backend API service
- Database with persistent storage
- Cache layer (Redis)
- Proper network segmentation
- Environment-specific configuration

This challenge tests your ability to architect and implement complex container networking and storage solutions.

## 🏆 Achievement Unlocked

Complete this module to earn your **"Networking Ninja"** badge! 🥷

## 🤔 Discussion Topics

After completing the labs, consider these questions:
1. How does container networking compare to traditional network setups?
2. What are the trade-offs between different storage approaches?
3. How do you ensure data security in containerized applications?
4. What networking patterns work best for microservices?

## 📖 Quick Reference

### Network Commands
```bash
# Network management
docker network ls                    # List networks
docker network create network_name  # Create network
docker network inspect network_name # Network details
docker network rm network_name      # Remove network

# Connect containers to networks
docker run --network network_name image
docker network connect network_name container
docker network disconnect network_name container
```

### Volume Commands
```bash
# Volume management
docker volume ls                    # List volumes
docker volume create volume_name    # Create volume
docker volume inspect volume_name   # Volume details
docker volume rm volume_name        # Remove volume

# Using volumes
docker run -v volume_name:/path image        # Named volume
docker run -v /host/path:/container/path image  # Bind mount
docker run -v /container/path image          # Anonymous volume
```

### Environment Variables
```bash
# Set environment variables
docker run -e VAR=value image
docker run -e VAR1=val1 -e VAR2=val2 image
docker run --env-file .env image

# View container environment
docker exec container env
docker inspect container | grep -A 10 "Env"
```

## 🔍 Networking and Storage Patterns

### Three-Tier Web Application
```
┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│   Frontend  │───▶│   Backend   │───▶│  Database   │
│  (nginx)    │    │ (app server)│    │  (MySQL)    │
│   Port 80   │    │  Port 8080  │    │  Port 3306  │
└─────────────┘    └─────────────┘    └─────────────┘
       │                   │                   │
       └───────────────────┼───────────────────┘
                          │
                   ┌─────────────┐
                   │   Network   │
                   │  (bridge)   │
                   └─────────────┘
```

### Microservices with Service Discovery
```
┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│   Gateway   │───▶│  Service A  │───▶│   Cache     │
│  (nginx)    │    │ (user-api)  │    │  (Redis)    │
└─────────────┘    └─────────────┘    └─────────────┘
       │                   │
       │            ┌─────────────┐
       └───────────▶│  Service B  │
                    │ (order-api) │
                    └─────────────┘
```

### Data Persistence Strategies
```
Container Lifecycle:
┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│   Created   │───▶│   Running   │───▶│   Stopped   │
└─────────────┘    └─────────────┘    └─────────────┘
                          │                   │
                          ▼                   ▼
                   ┌─────────────┐    ┌─────────────┐
                   │    Data     │    │    Data     │
                   │ (ephemeral) │    │   (lost!)   │
                   └─────────────┘    └─────────────┘

With Volumes:
┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│   Created   │───▶│   Running   │───▶│   Stopped   │
└─────────────┘    └─────────────┘    └─────────────┘
       │                   │                   │
       └───────────────────┼───────────────────┘
                          │
                   ┌─────────────┐
                   │   Volume    │
                   │ (persistent)│
                   └─────────────┘
```

## 🚀 Ready to Start?

Head over to [Lesson 1: Container Networking Fundamentals](lessons/01-networking-fundamentals.md) and let's start connecting your containers!

Remember: Great applications aren't just individual containers - they're orchestrated systems that work together seamlessly! 🌐

---

## 🆘 Need Help?

- **Containers can't communicate?** Check network configuration and container names
- **Data disappearing?** Verify volume mounts and persistence setup
- **Port conflicts?** Use different host ports or check what's already running
- **Performance issues?** Monitor resource usage and optimize accordingly

## 🎯 Pro Tips

1. **Plan your network architecture** before building
2. **Use meaningful network names** for clarity
3. **Always use volumes** for important data
4. **Test connectivity** between containers regularly
5. **Monitor resource usage** to optimize performance

*"Containers that work together, stay together!"* - Let's build connected systems! 🔗
