# 🐳 Docker Commands Cheat Sheet

*Your quick reference for Docker mastery*

## 🚀 Container Lifecycle

### Running Containers
```bash
# Basic run
docker run image_name                    # Run a container
docker run -d image_name                 # Run in background (detached)
docker run -it image_name bash           # Interactive with terminal
docker run --name my-container image     # Assign a name
docker run --rm image_name               # Remove when stopped

# With port mapping
docker run -p 8080:80 nginx             # Map host:container ports
docker run -p 127.0.0.1:8080:80 nginx   # Bind to specific interface

# With environment variables
docker run -e VAR_NAME=value image      # Set environment variable
docker run -e VAR1=val1 -e VAR2=val2 image  # Multiple variables

# With volumes
docker run -v /host/path:/container/path image    # Bind mount
docker run -v volume_name:/container/path image   # Named volume
```

### Managing Running Containers
```bash
docker ps                               # List running containers
docker ps -a                            # List all containers (including stopped)
docker ps -q                            # List only container IDs
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"  # Custom format

docker stop container_name               # Stop gracefully
docker kill container_name               # Force stop
docker restart container_name            # Restart container
docker pause container_name              # Pause container
docker unpause container_name            # Unpause container
```

### Container Information
```bash
docker logs container_name               # View logs
docker logs -f container_name            # Follow logs (like tail -f)
docker logs --tail 50 container_name     # Last 50 lines
docker logs --since 2h container_name    # Logs from last 2 hours

docker inspect container_name            # Detailed container info
docker stats                            # Live resource usage
docker stats container_name              # Stats for specific container
docker top container_name                # Running processes in container
```

### Executing Commands in Containers
```bash
docker exec -it container_name bash      # Interactive shell
docker exec container_name ls -la        # Run single command
docker exec -u root container_name bash  # Run as specific user
```

### Removing Containers
```bash
docker rm container_name                 # Remove stopped container
docker rm -f container_name              # Force remove running container
docker rm $(docker ps -aq)              # Remove all containers
docker container prune                   # Remove all stopped containers
```

## 📦 Image Management

### Working with Images
```bash
docker images                           # List local images
docker images -q                        # List only image IDs
docker pull image_name                  # Download image
docker pull image_name:tag              # Download specific tag
docker push image_name                  # Upload image to registry

docker search keyword                   # Search Docker Hub
docker history image_name               # Show image layers
docker inspect image_name               # Detailed image info
```

### Building Images
```bash
docker build .                         # Build from current directory
docker build -t my-image .             # Build with tag
docker build -t my-image:v1.0 .        # Build with specific tag
docker build -f Dockerfile.prod .      # Use specific Dockerfile
docker build --no-cache .              # Build without cache
```

### Removing Images
```bash
docker rmi image_name                   # Remove image
docker rmi -f image_name                # Force remove image
docker rmi $(docker images -q)         # Remove all images
docker image prune                      # Remove unused images
docker image prune -a                   # Remove all unused images
```

## 🌐 Networking

### Network Management
```bash
docker network ls                       # List networks
docker network create network_name      # Create network
docker network inspect network_name     # Network details
docker network rm network_name          # Remove network

# Connect containers to networks
docker run --network network_name image
docker network connect network_name container_name
docker network disconnect network_name container_name
```

### Port Operations
```bash
docker port container_name              # Show port mappings
docker run -p 8080:80 image            # Map port 8080 to 80
docker run -p 127.0.0.1:8080:80 image  # Bind to localhost only
docker run -P image                     # Map all exposed ports randomly
```

## 💾 Volume Management

### Volume Operations
```bash
docker volume ls                        # List volumes
docker volume create volume_name        # Create volume
docker volume inspect volume_name       # Volume details
docker volume rm volume_name            # Remove volume
docker volume prune                     # Remove unused volumes

# Using volumes
docker run -v volume_name:/path image   # Named volume
docker run -v /host/path:/container/path image  # Bind mount
docker run -v /container/path image     # Anonymous volume
```

## 🔧 System Management

### System Information
```bash
docker version                          # Docker version info
docker info                            # System-wide information
docker system df                       # Disk usage
docker system events                   # Real-time events
docker system prune                    # Clean up everything unused
docker system prune -a                 # Clean up everything (including unused images)
```

### Resource Management
```bash
# Memory and CPU limits
docker run -m 512m image               # Limit memory to 512MB
docker run --cpus="1.5" image          # Limit to 1.5 CPUs
docker run --memory=1g --cpus="2" image # Both limits

# Resource monitoring
docker stats                           # Live resource usage
docker stats --no-stream               # One-time stats snapshot
```

## 🐳 Docker Compose (Quick Reference)

### Basic Compose Commands
```bash
docker-compose up                       # Start services
docker-compose up -d                    # Start in background
docker-compose down                     # Stop and remove services
docker-compose ps                       # List services
docker-compose logs                     # View logs
docker-compose logs -f service_name     # Follow specific service logs
docker-compose exec service_name bash   # Execute command in service
docker-compose build                    # Build services
docker-compose pull                     # Pull service images
```

## 🎯 Common Patterns

### Development Workflow
```bash
# Quick development server
docker run -d -p 8080:80 -v $(pwd):/usr/share/nginx/html nginx

# Database for development
docker run -d -p 3306:3306 -e MYSQL_ROOT_PASSWORD=dev mysql:8.0

# Interactive debugging
docker run -it --rm -v $(pwd):/app -w /app node:16 bash
```

### Production Patterns
```bash
# Health checks
docker run --health-cmd="curl -f http://localhost/" nginx

# Restart policies
docker run --restart=unless-stopped nginx
docker run --restart=always nginx

# Resource limits for production
docker run -m 1g --cpus="2" --restart=unless-stopped nginx
```

### Cleanup Patterns
```bash
# Clean up everything
docker system prune -a --volumes

# Remove all stopped containers
docker container prune

# Remove unused images
docker image prune -a

# Remove unused volumes
docker volume prune

# Remove unused networks
docker network prune
```

## 🔍 Troubleshooting Commands

### Debugging Containers
```bash
# Check if container is running
docker ps | grep container_name

# View recent logs
docker logs --tail 100 container_name

# Get shell access
docker exec -it container_name bash
docker exec -it container_name sh      # If bash not available

# Check resource usage
docker stats container_name

# Inspect configuration
docker inspect container_name | jq '.[0].Config'
```

### Network Troubleshooting
```bash
# Test connectivity between containers
docker exec container1 ping container2

# Check port bindings
docker port container_name

# List network connections
docker network ls
docker network inspect bridge
```

## 🎨 Useful Aliases

Add these to your `~/.zshrc` or `~/.bashrc`:

```bash
# Docker shortcuts (already set up in our environment)
alias d='docker'
alias dc='docker-compose'
alias dps='docker ps'
alias di='docker images'
alias dex='docker exec -it'
alias dlog='docker logs'

# Cleanup aliases
alias docker-clean='docker system prune -a --volumes'
alias docker-stop-all='docker stop $(docker ps -q)'
alias docker-rm-all='docker rm $(docker ps -aq)'
```

## 📊 Format Options

### Custom PS Format
```bash
# Custom container listing
docker ps --format "table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}"

# JSON output
docker ps --format json

# Only names
docker ps --format "{{.Names}}"
```

### Custom Images Format
```bash
# Custom image listing
docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}"

# Show only repository names
docker images --format "{{.Repository}}"
```

## 🆘 Emergency Commands

| Problem | Command | Description |
|---------|---------|-------------|
| **Container won't stop** | `docker kill container_name` | Force stop |
| **Out of disk space** | `docker system prune -a --volumes` | Clean everything |
| **Can't connect to Docker** | `sudo systemctl restart docker` | Restart Docker service |
| **Permission denied** | `sudo usermod -aG docker $USER` | Add user to docker group |
| **Container keeps restarting** | `docker logs container_name` | Check logs for errors |

---

*Remember: When in doubt, check the logs with `docker logs container_name`!* 📋
