# 🔧 Lesson 2: Docker Installation and Setup

*"Getting Docker ready for action on Ubuntu Linux"*

Great! You understand what containers are and why they're amazing. Now let's get Docker installed and configured so you can start using this powerful technology. Don't worry - our learning environment has already done most of the heavy lifting, but understanding the process is crucial for real-world deployments.

## 🎯 What You'll Learn

- How Docker is installed on Ubuntu systems
- Understanding Docker architecture and components
- Verifying your Docker installation
- Basic Docker configuration
- **Ubuntu vs RHEL**: Installation differences between distributions
- Security considerations for Docker setup
- Troubleshooting common installation issues

## 🏗️ Docker Architecture Overview

Before we dive into installation, let's understand what we're installing:

### Docker Components

**Docker Engine** consists of:
- **Docker Daemon** (`dockerd`) - The background service that manages containers
- **Docker CLI** (`docker`) - The command-line interface you use
- **Docker API** - REST API for programmatic access

**Additional Components:**
- **Docker Compose** - Tool for defining multi-container applications
- **Docker Registry** - Storage for Docker images (Docker Hub is the public registry)
- **Docker Networks** - Virtual networks for container communication
- **Docker Volumes** - Persistent storage for containers

### How It All Works Together

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Docker CLI    │───▶│  Docker Daemon  │───▶│   Containers    │
│   (docker)      │    │   (dockerd)     │    │                 │
└─────────────────┘    └─────────────────┘    └─────────────────┘
                              │
                              ▼
                       ┌─────────────────┐
                       │  Docker Images  │
                       │   & Networks    │
                       └─────────────────┘
```

## 📦 Docker Installation on Ubuntu Systems

### Our Learning Environment

**Good news!** Our learning environment already has Docker installed and configured. But let's understand how it would be done on a real Ubuntu system.

### Real-World Ubuntu Installation Process

On a real Ubuntu system, you would:

1. **Update your package lists:**
   ```bash
   sudo apt update
   ```

2. **Install prerequisites:**
   ```bash
   sudo apt install apt-transport-https ca-certificates curl gnupg lsb-release
   ```

3. **Add Docker's official GPG key:**
   ```bash
   curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
   ```

4. **Add Docker repository:**
   ```bash
   echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
   ```

5. **Install Docker:**
   ```bash
   sudo apt update
   sudo apt install docker-ce docker-ce-cli containerd.io docker-compose-plugin
   ```

6. **Start and enable Docker:**
   ```bash
   sudo systemctl start docker
   sudo systemctl enable docker
   ```

7. **Add your user to the docker group:**
   ```bash
   sudo usermod -aG docker $USER
   ```

8. **Log out and back in** (or restart) for group changes to take effect.

## 🔄 Ubuntu vs RHEL Installation Comparison

Here's how Docker installation differs between Ubuntu and RHEL:

### Ubuntu Installation
```bash
# Add Docker repository
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# Install Docker
sudo apt update
sudo apt install docker-ce docker-ce-cli containerd.io

# Start Docker
sudo systemctl start docker
sudo systemctl enable docker
```

### RHEL Installation
```bash
# Add Docker repository
sudo dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

# Install Docker
sudo dnf install docker-ce docker-ce-cli containerd.io

# Start Docker
sudo systemctl start docker
sudo systemctl enable docker
```

### Key Differences
- **Package manager**: Ubuntu uses `apt`, RHEL uses `dnf`
- **Repository setup**: Different GPG keys and repository URLs
- **Package names**: Same Docker packages, different base system packages
- **Service management**: Both use `systemctl` (identical commands!)

### What Our Environment Does

Our setup script automatically:
- ✅ Installs Docker Engine using the devcontainer feature
- ✅ Starts the Docker service
- ✅ Adds your user to the docker group
- ✅ Configures Docker for development use

## 🔍 Verifying Your Docker Installation

Let's make sure everything is working correctly!

### Basic Verification Commands

```bash
# Check Docker version
docker --version

# Check Docker system information
docker info

# Check if Docker daemon is running
docker ps
```

**Try these now:**
```bash
docker --version
docker info
docker ps
```

### Understanding Docker Info Output

The `docker info` command shows important information:
- **Server Version** - Docker Engine version
- **Storage Driver** - How Docker stores images and containers
- **Cgroup Driver** - Container resource management
- **Registry** - Default image registry (Docker Hub)
- **Security Options** - Security features enabled

## 🧪 Lab 2: Docker Installation Verification

Let's thoroughly test your Docker installation!

### Task 1: Basic Docker Commands

1. **Check Docker version and info:**
   ```bash
   docker --version
   docker version    # More detailed version info
   docker info       # System information
   ```

2. **Verify Docker daemon is running:**
   ```bash
   docker ps         # Should show empty list (no containers running)
   docker images     # Should show empty list (no images downloaded)
   ```

3. **Check your user permissions:**
   ```bash
   groups            # Should include 'docker' group
   id                # Should show docker group membership
   ```

### Task 2: First Docker Command Test

1. **Run the Docker hello-world test:**
   ```bash
   docker run hello-world
   ```

   This command:
   - Downloads the `hello-world` image
   - Creates a container from it
   - Runs the container
   - Shows a success message
   - Exits and removes the container

2. **Verify the image was downloaded:**
   ```bash
   docker images
   ```

   You should see the `hello-world` image listed.

### Task 3: Docker System Information

1. **Get detailed system information:**
   ```bash
   docker system info
   ```

2. **Check Docker disk usage:**
   ```bash
   docker system df
   ```

3. **View Docker system events (in another terminal if possible):**
   ```bash
   docker system events
   ```

   Leave this running and execute Docker commands in another terminal to see real-time events.

### Task 4: Testing Container Operations

1. **Run a simple interactive container:**
   ```bash
   docker run -it ubuntu:22.04 bash
   ```

   This will:
   - Download Ubuntu 22.04 image
   - Start an interactive container
   - Give you a bash shell inside the container

2. **Inside the container, try some commands:**
   ```bash
   whoami          # You're root inside the container
   ls /            # See the Ubuntu file system
   cat /etc/os-release  # Check the OS version
   apt update      # Update package lists (inside container)
   exit            # Exit the container
   ```

3. **Back on your host, check what happened:**
   ```bash
   docker ps       # No running containers
   docker ps -a    # Shows stopped containers
   docker images   # Shows downloaded images
   ```

## ⚙️ Docker Configuration

### Docker Configuration Files

Docker uses several configuration files:

**System-wide configuration:**
- `/etc/docker/daemon.json` - Docker daemon configuration
- `/etc/systemd/system/docker.service.d/` - Systemd service overrides

**User configuration:**
- `~/.docker/config.json` - Docker CLI configuration

### Basic Daemon Configuration

Here's an example `/etc/docker/daemon.json`:

```json
{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  },
  "storage-driver": "overlay2"
}
```

### Viewing Current Configuration

```bash
# View daemon configuration
docker info | grep -A 10 "Server:"

# View storage information
docker info | grep -A 5 "Storage Driver"

# View logging configuration
docker info | grep -A 3 "Logging Driver"
```

## 🛡️ Security Considerations

### Docker Security Basics

**Important Security Points:**

1. **Docker daemon runs as root** - This is necessary but requires careful management
2. **Users in docker group have root-equivalent access** - Only add trusted users
3. **Containers share the host kernel** - Unlike VMs, they're not fully isolated
4. **Images can contain vulnerabilities** - Only use trusted images

### Best Practices

✅ **DO:**
- Keep Docker updated
- Use official images when possible
- Scan images for vulnerabilities
- Run containers as non-root users when possible
- Use resource limits

❌ **DON'T:**
- Add untrusted users to docker group
- Run untrusted containers with privileged access
- Use images from unknown sources
- Ignore security updates

## 🔧 Troubleshooting Common Issues

### "Permission denied" errors

**Problem:** `Got permission denied while trying to connect to the Docker daemon socket`

**Solutions:**
```bash
# Check if you're in docker group
groups

# If not in docker group, add yourself (requires sudo)
sudo usermod -aG docker $USER

# Log out and back in, or use:
newgrp docker

# Test again
docker ps
```

### "Docker daemon not running"

**Problem:** `Cannot connect to the Docker daemon`

**Solutions:**
```bash
# Check if Docker service is running
systemctl status docker

# Start Docker service
sudo systemctl start docker

# Enable Docker to start on boot
sudo systemctl enable docker
```

### "No space left on device"

**Problem:** Docker runs out of disk space

**Solutions:**
```bash
# Check Docker disk usage
docker system df

# Clean up unused resources
docker system prune

# Remove unused images
docker image prune

# Remove unused volumes
docker volume prune
```

### Ubuntu vs RHEL Troubleshooting

**Ubuntu-specific issues:**
- Package conflicts with `snap` Docker installation
- AppArmor security policies
- UFW firewall rules

**RHEL-specific issues:**
- SELinux security contexts
- Firewalld configuration
- Subscription manager conflicts

**Common solutions work on both:**
- Service management with `systemctl`
- User group management
- Docker daemon configuration

## 🏆 Knowledge Check

Before moving on, make sure you can:
- [ ] Verify Docker is installed and running
- [ ] Run basic Docker commands without sudo
- [ ] Understand Docker architecture components
- [ ] Check Docker system information
- [ ] Troubleshoot basic Docker issues
- [ ] Understand Docker security considerations
- [ ] Know the differences between Ubuntu and RHEL Docker installation

## 🎯 Quick Challenge

Test your Docker installation by:

1. **Checking Docker version and system info**
2. **Running the hello-world container**
3. **Starting an interactive Ubuntu container**
4. **Listing images and containers**
5. **Cleaning up test containers**

**Solution:**
```bash
# Check installation
docker --version
docker info

# Test with hello-world
docker run hello-world

# Interactive test
docker run -it ubuntu:22.04 bash
# (inside container) whoami && apt update && exit

# Check what we created
docker images
docker ps -a

# Clean up
docker container prune
docker image prune
```

## 🔄 RHEL Equivalent Commands

If you were doing this on a RHEL system, the Docker commands would be identical:

```bash
# Same Docker commands work on both Ubuntu and RHEL!
docker --version
docker info
docker run hello-world
docker run -it registry.access.redhat.com/ubi8/ubi bash
```

The only differences are:
- Installation process (dnf vs apt)
- Base images (Ubuntu vs RHEL UBI)
- System-specific troubleshooting

## 🚀 What's Next?

Perfect! Docker is installed and working on Ubuntu. In the next lesson, [Your First Container Adventure](03-first-container.md), we'll start running real containers and learn the fundamental Docker commands you'll use every day.

## 📝 Quick Reference Card

```bash
# Installation verification
docker --version           # Check Docker version
docker info                # System information
docker ps                  # List running containers

# System management
docker system df           # Show disk usage
docker system prune        # Clean up unused resources
docker system events       # Show real-time events

# Service management (Ubuntu & RHEL)
systemctl status docker    # Check Docker service
systemctl start docker     # Start Docker service
systemctl enable docker    # Enable on boot

# User management (Ubuntu & RHEL)
groups                     # Check group membership
sudo usermod -aG docker $USER  # Add user to docker group
```

## 🌟 Pro Tips

1. **Always verify installation** with `docker run hello-world`
2. **Check disk usage regularly** with `docker system df`
3. **Keep Docker updated** for security and features
4. **Monitor Docker logs** with `journalctl -u docker`
5. **Use resource limits** in production environments
6. **Docker commands are identical** on Ubuntu and RHEL - learn once, use everywhere!

---

*"A journey of a thousand containers begins with a single installation."* - Your Docker environment is ready on Ubuntu! 🐳

### 🎓 Ubuntu vs RHEL Summary

You've learned Docker installation concepts that apply to both:
- **Ubuntu skills**: `apt` package management, Ubuntu-specific troubleshooting
- **RHEL awareness**: `dnf` package management, enterprise considerations
- **Universal Docker skills**: All Docker commands work identically on both platforms

The beauty of Docker is that once it's installed, the experience is identical regardless of the underlying Linux distribution!
