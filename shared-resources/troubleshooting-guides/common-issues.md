# 🔧 Troubleshooting Guide: Common Issues and Solutions

*"When things go wrong, here's how to make them right!"*

## 🎯 General Troubleshooting Approach

### The CALM Method
1. **C**heck the basics (is it running? connected? configured?)
2. **A**nalyze the logs (what do the error messages say?)
3. **L**ook for patterns (does this happen consistently?)
4. **M**ethodically test solutions (one change at a time)

### Essential Debugging Commands
```bash
# System status
docker --version                    # Check Docker installation
docker info                        # Docker system information
systemctl status docker            # Docker service status

# Container debugging
docker ps -a                       # List all containers
docker logs container_name          # View container logs
docker inspect container_name       # Detailed container info
docker exec -it container_name bash # Get shell access

# Resource monitoring
docker stats                       # Live resource usage
df -h                              # Disk space
free -h                            # Memory usage
```

## 🐳 Docker Installation Issues

### Problem: "docker: command not found"
**Symptoms**: Docker commands don't work
**Causes**: Docker not installed or not in PATH
**Solutions**:
```bash
# Check if Docker is installed
which docker

# If not installed, install Docker
sudo dnf install -y docker-ce docker-ce-cli containerd.io

# Start Docker service
sudo systemctl start docker
sudo systemctl enable docker
```

### Problem: "Permission denied" when running Docker commands
**Symptoms**: "Got permission denied while trying to connect to the Docker daemon socket"
**Causes**: User not in docker group
**Solutions**:
```bash
# Add user to docker group
sudo usermod -aG docker $USER

# Log out and back in, or run:
newgrp docker

# Verify group membership
groups $USER
```

### Problem: Docker service won't start
**Symptoms**: "Failed to start docker.service"
**Causes**: Service configuration issues, port conflicts
**Solutions**:
```bash
# Check service status
sudo systemctl status docker

# View detailed logs
sudo journalctl -u docker.service

# Restart Docker service
sudo systemctl restart docker

# Check for port conflicts
sudo netstat -tulpn | grep :2376
```

## 📦 Container Runtime Issues

### Problem: "Unable to find image" error
**Symptoms**: `docker: Error response from daemon: pull access denied`
**Causes**: Image name typo, network issues, private registry access
**Solutions**:
```bash
# Check image name spelling
docker search nginx

# Try pulling explicitly
docker pull nginx:latest

# Check network connectivity
ping docker.io

# For private registries, login first
docker login registry.example.com
```

### Problem: Container exits immediately
**Symptoms**: Container starts then stops right away
**Causes**: Application crashes, missing dependencies, wrong command
**Solutions**:
```bash
# Check container logs
docker logs container_name

# Run container interactively to debug
docker run -it image_name bash

# Check the Dockerfile CMD/ENTRYPOINT
docker inspect image_name | grep -A 5 "Cmd\|Entrypoint"

# Override entrypoint for debugging
docker run -it --entrypoint bash image_name
```

### Problem: "Port already in use" error
**Symptoms**: `bind: address already in use`
**Causes**: Another process using the port
**Solutions**:
```bash
# Find what's using the port
sudo netstat -tulpn | grep :8080
sudo lsof -i :8080

# Kill the process using the port
sudo kill -9 PID

# Use a different port
docker run -p 8081:80 nginx

# Stop conflicting containers
docker ps
docker stop conflicting_container
```

### Problem: Container can't connect to other containers
**Symptoms**: Connection refused, network timeouts
**Causes**: Network configuration, firewall, wrong hostnames
**Solutions**:
```bash
# Check container networks
docker network ls
docker network inspect bridge

# Test connectivity between containers
docker exec container1 ping container2

# Use container names for communication
# Instead of IP addresses, use service names

# Check if containers are on same network
docker inspect container1 | grep NetworkMode
docker inspect container2 | grep NetworkMode
```

## 🌐 Networking Issues

### Problem: Can't access containerized web application
**Symptoms**: Browser shows "This site can't be reached"
**Causes**: Port mapping issues, firewall, wrong IP
**Solutions**:
```bash
# Check port mappings
docker port container_name

# Verify container is running
docker ps

# Test locally first
curl http://localhost:8080

# Check firewall settings
sudo firewall-cmd --list-all

# Try different port
docker run -p 8081:80 nginx
```

### Problem: Container can't access external internet
**Symptoms**: DNS resolution fails, can't download packages
**Causes**: DNS configuration, network policies
**Solutions**:
```bash
# Test DNS inside container
docker exec container_name nslookup google.com

# Check Docker daemon DNS settings
docker info | grep -i dns

# Restart Docker with custom DNS
sudo systemctl edit docker
# Add:
# [Service]
# ExecStart=
# ExecStart=/usr/bin/dockerd --dns=8.8.8.8

# Restart Docker
sudo systemctl restart docker
```

## 💾 Storage and Volume Issues

### Problem: Data disappears when container restarts
**Symptoms**: Files created in container are lost after restart
**Causes**: No persistent storage configured
**Solutions**:
```bash
# Use named volumes
docker run -v mydata:/app/data nginx

# Use bind mounts
docker run -v /host/path:/container/path nginx

# Check existing volumes
docker volume ls

# Inspect volume details
docker volume inspect mydata
```

### Problem: "No space left on device" error
**Symptoms**: Container fails to start or write files
**Causes**: Disk space exhaustion
**Solutions**:
```bash
# Check disk usage
df -h
docker system df

# Clean up unused resources
docker system prune -a

# Remove unused volumes
docker volume prune

# Remove unused images
docker image prune -a

# Check specific directory usage
du -sh /var/lib/docker/*
```

### Problem: Permission denied accessing mounted volumes
**Symptoms**: Can't read/write files in mounted directories
**Causes**: File ownership/permission issues
**Solutions**:
```bash
# Check file permissions
ls -la /host/path

# Fix ownership (be careful!)
sudo chown -R 1000:1000 /host/path

# Run container as specific user
docker run -u 1000:1000 -v /host/path:/container/path image

# Check container user
docker exec container_name id
```

## 🏗️ Image Building Issues

### Problem: "COPY failed" during image build
**Symptoms**: `COPY failed: stat /var/lib/docker/tmp/.../file: no such file or directory`
**Causes**: File doesn't exist, wrong path, .dockerignore
**Solutions**:
```bash
# Check file exists in build context
ls -la file_name

# Check .dockerignore file
cat .dockerignore

# Verify build context
docker build --no-cache .

# Use absolute paths in Dockerfile
COPY ./src/app.js /app/app.js
```

### Problem: "Package not found" during build
**Symptoms**: Package manager can't find packages
**Causes**: Outdated package lists, wrong repository
**Solutions**:
```dockerfile
# Update package lists first
RUN dnf update -y && dnf install -y package_name

# For Ubuntu/Debian images
RUN apt-get update && apt-get install -y package_name

# Clean up after installation
RUN dnf clean all
```

### Problem: Build takes too long or fails
**Symptoms**: Build hangs or times out
**Causes**: Large build context, network issues, inefficient Dockerfile
**Solutions**:
```bash
# Use .dockerignore to exclude unnecessary files
echo "node_modules" >> .dockerignore
echo "*.log" >> .dockerignore

# Use multi-stage builds
FROM node:16 AS builder
# ... build steps
FROM node:16-alpine
COPY --from=builder /app/dist /app

# Use build cache effectively
# Put frequently changing commands last
```

## 🐙 Docker Compose Issues

### Problem: "Service 'web' failed to build"
**Symptoms**: docker-compose up fails during build
**Causes**: Dockerfile errors, missing files
**Solutions**:
```bash
# Build services individually
docker-compose build web

# Force rebuild without cache
docker-compose build --no-cache web

# Check build context
docker-compose config

# View detailed build output
docker-compose up --build
```

### Problem: Services can't communicate
**Symptoms**: Connection refused between services
**Causes**: Network configuration, service names
**Solutions**:
```yaml
# Use service names for communication
version: '3.8'
services:
  web:
    # ...
    environment:
      - DB_HOST=database  # Use service name
  database:
    # ...
```

```bash
# Check service networks
docker-compose ps
docker network ls

# Test connectivity
docker-compose exec web ping database
```

### Problem: "Port is already allocated"
**Symptoms**: Can't start services due to port conflicts
**Causes**: Port already in use by another service
**Solutions**:
```bash
# Check what's using the port
sudo netstat -tulpn | grep :80

# Change port in docker-compose.yml
services:
  web:
    ports:
      - "8080:80"  # Use different host port

# Stop conflicting services
docker-compose down
```

## 🔍 Performance Issues

### Problem: Container runs slowly
**Symptoms**: Application response times are poor
**Causes**: Resource constraints, inefficient configuration
**Solutions**:
```bash
# Check resource usage
docker stats container_name

# Increase resource limits
docker run -m 2g --cpus="2" image_name

# In docker-compose.yml:
services:
  web:
    deploy:
      resources:
        limits:
          memory: 2G
          cpus: '2'
```

### Problem: High memory usage
**Symptoms**: System becomes unresponsive
**Causes**: Memory leaks, too many containers
**Solutions**:
```bash
# Monitor memory usage
docker stats --no-stream

# Set memory limits
docker run -m 512m image_name

# Clean up unused containers
docker container prune

# Check for memory leaks in application
docker exec container_name top
```

## 🚨 Emergency Procedures

### Complete Docker Reset
```bash
# Stop all containers
docker stop $(docker ps -q)

# Remove all containers
docker rm $(docker ps -aq)

# Remove all images
docker rmi $(docker images -q)

# Remove all volumes
docker volume rm $(docker volume ls -q)

# Remove all networks
docker network rm $(docker network ls -q)

# Clean everything
docker system prune -a --volumes
```

### Docker Service Recovery
```bash
# Restart Docker service
sudo systemctl restart docker

# If that fails, reset Docker
sudo systemctl stop docker
sudo rm -rf /var/lib/docker
sudo systemctl start docker
```

### System Resource Recovery
```bash
# Free up disk space
sudo dnf clean all
docker system prune -a --volumes

# Clear logs
sudo journalctl --vacuum-time=1d

# Restart system if needed
sudo reboot
```

## 📋 Diagnostic Information Collection

When asking for help, collect this information:

```bash
# System information
uname -a
cat /etc/rocky-release
docker --version
docker info

# Container information
docker ps -a
docker images
docker logs container_name

# Network information
docker network ls
ip addr show

# Resource information
df -h
free -h
docker system df
```

## 🎯 Prevention Tips

### Best Practices to Avoid Issues
1. **Always check logs first**: `docker logs container_name`
2. **Use specific image tags**: `nginx:1.21` instead of `nginx:latest`
3. **Set resource limits**: Prevent containers from consuming all resources
4. **Use health checks**: Monitor container health automatically
5. **Regular cleanup**: Run `docker system prune` regularly
6. **Monitor disk space**: Keep an eye on `/var/lib/docker`
7. **Use .dockerignore**: Exclude unnecessary files from build context
8. **Test incrementally**: Build and test one component at a time

### Monitoring Commands to Run Regularly
```bash
# Weekly cleanup
docker system prune

# Check resource usage
docker stats --no-stream

# Monitor disk space
df -h /var/lib/docker

# Check for failed containers
docker ps -a --filter "status=exited"
```

---

*Remember: Most Docker issues are configuration problems, not bugs. Take your time, read the error messages carefully, and check the basics first!* 🔍
