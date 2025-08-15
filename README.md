# 🐳 Docker & Ubuntu Linux Learning Journey

**From Windows to Containers: A Hands-On Learning Adventure**

Welcome to your journey from Windows IT professional to Linux container expert! This course is designed specifically for IT operations team members who are comfortable with Windows environments and want to master Docker containers on Ubuntu Linux, while learning how concepts translate to RHEL-based systems.

## 🎯 Course Overview

This isn't just another technical manual - it's your guided adventure into the world of Linux and containers. We'll bridge the gap between familiar Windows concepts and powerful Linux/Docker capabilities through hands-on labs, real-world scenarios, and just enough humor to keep things interesting.

### Who This Course Is For
- IT professionals with Windows backgrounds
- Team members comfortable with command line basics
- Anyone who wants to understand containers without the DevOps complexity
- People who learn best by doing, not just reading

### What You'll Learn
By the end of this journey, you'll be able to:
- Navigate Ubuntu Linux like a pro (goodbye C:\ drives!)
- Understand key differences between Ubuntu and RHEL-based systems
- Deploy and manage Docker containers confidently
- Build custom container images for web applications
- Orchestrate multi-container applications
- Apply security best practices for production environments
- Troubleshoot container issues like a seasoned expert

## 🚀 Getting Started

### Prerequisites
- Basic computer skills and command line comfort
- A GitHub account
- Enthusiasm for learning new things!

### Launch Your Learning Environment
1. **Fork this repository** to your GitHub account
2. **Open in GitHub Codespaces** - click the green "Code" button and select "Create codespace on main"
3. **Wait for the magic** - your Ubuntu Linux environment with Docker will be ready in a few minutes
4. **Start with Module 1** and begin your container journey!

## 📚 Course Modules

### 🚀 [Module 1: Welcome to Ubuntu Linux - Your New Command Center](modules/01-ubuntu-linux-basics/)
*"Trading PowerShell for Bash - It's not so scary!"*
- Windows vs Linux command translations
- Ubuntu vs RHEL system differences
- File system navigation and permissions
- Package management with apt (and how it compares to dnf)
- Setting up your workspace
- Complete with 5 hands-on lessons

### 🐳 [Module 2: Meet Docker - Your Application Packaging Superhero](modules/02-docker-fundamentals/)
*"Think of containers like really smart ZIP files that can run"*
- Container concepts and benefits
- Docker installation on Ubuntu (with RHEL notes)
- Running your first web server
- Container lifecycle management
- Complete with 5 hands-on lessons

### 🏗️ [Module 3: Building Your Container Empire](modules/03-building-images/)
*"From consumer to creator - building your own containers"*
- Understanding Docker images
- Writing Dockerfiles
- Building custom images
- Working with Ubuntu base images (and Universal Base Images)
- Module structure ready for lesson development

### 🌐 [Module 4: Connecting the Dots - Networking and Storage](modules/04-networking-storage/)
*"Making containers talk to each other and remember things"*
- Container networking basics
- Persistent storage solutions
- Environment configuration
- Multi-container communication
- Module structure ready for lesson development

### 🎭 [Module 5: Orchestrating the Show - Multi-Container Applications](modules/05-docker-compose/)
*"Conducting your container orchestra with Docker Compose"*
- Docker Compose fundamentals
- Service orchestration
- Scaling and load balancing
- Complete web stack deployment
- Module structure ready for lesson development

### 🛡️ [Module 6: Production Ready - Security and Best Practices](modules/06-production-ready/)
*"From playground to production - keeping things secure and stable"*
- Container security fundamentals
- Resource management and monitoring
- Logging and troubleshooting
- Backup and recovery strategies
- Module structure ready for lesson development

## 🎮 Learning Features

### 🏆 Achievement System
Earn badges as you progress:
- **First Container Captain** - Successfully run your first container
- **Dockerfile Developer** - Build your first custom image
- **Networking Ninja** - Connect multiple containers
- **Compose Conductor** - Orchestrate a multi-service application
- **Security Sentinel** - Implement production security practices

### 🔧 Hands-On Labs
Each module includes practical labs with:
- Real-world scenarios
- Step-by-step guidance
- Validation checkpoints
- Extension challenges for advanced learners

### 📖 Learning Resources
- **Cheat Sheets**: Quick reference guides with Ubuntu and RHEL comparisons
- **Troubleshooting Guides**: Common issues and solutions
- **Visual Diagrams**: Network and architecture illustrations
- **"Oops!" Sections**: Learn from common mistakes
- **Ubuntu vs RHEL**: Side-by-side comparisons throughout

## 🔄 Ubuntu vs RHEL Learning Approach

This course uses Ubuntu as the primary learning platform while teaching you about RHEL differences:

### Why Ubuntu First?
- **Beginner-friendly** - Great package management and documentation
- **Widely used** - Popular in cloud and development environments
- **Docker-friendly** - Excellent Docker support and integration
- **Clean foundation** - Learn core concepts without complexity

### RHEL Knowledge Integration
Throughout the course, you'll see:
- 📦 **Package Management**: `apt` vs `dnf` comparisons
- 🔧 **Command Differences**: Ubuntu and RHEL side-by-side
- 📁 **File Locations**: Where things differ between distributions
- 🏢 **Enterprise Focus**: When and why to choose RHEL

### Real-World Preparation
By the end, you'll understand:
- How to work in Ubuntu environments
- How to adapt skills to RHEL/CentOS systems
- When to choose each distribution
- How Docker works the same on both

## 🎯 Final Project

Put it all together by deploying a complete web service stack including:
- Load balancer
- Web application servers
- Database backend
- Monitoring and logging
- Security hardening

## 🤝 Getting Help

- **Discussion Topics**: Each module includes discussion prompts
- **Peer Learning**: Work together and share knowledge
- **Instructor Notes**: Additional guidance and challenges
- **Community Support**: Learn from each other's experiences

## 📋 Course Progress Tracker

- [ ] Module 1: Ubuntu Linux Basics (with RHEL comparisons)
- [ ] Module 2: Docker Fundamentals  
- [ ] Module 3: Building Images
- [ ] Module 4: Networking & Storage
- [ ] Module 5: Docker Compose
- [ ] Module 6: Production Ready
- [ ] Final Project: Complete Web Stack

---

## 🌟 Ready to Begin?

Your container journey starts now! Head over to [Module 1](modules/01-ubuntu-linux-basics/) and let's transform you from a Windows professional into a Linux container expert.

Remember: Every expert was once a beginner. The only difference is they started!

---

## 🔍 Quick Reference

### Ubuntu Package Management
```bash
sudo apt update              # Update package lists
sudo apt install package    # Install a package
apt search keyword          # Search for packages
sudo apt remove package     # Remove a package
apt list --installed        # List installed packages
```

### RHEL Equivalent Commands
```bash
sudo dnf update             # Update package lists
sudo dnf install package   # Install a package
dnf search keyword         # Search for packages
sudo dnf remove package    # Remove a package
dnf list installed         # List installed packages
```

### Docker Commands (Same on Both!)
```bash
docker --version           # Check Docker version
docker run hello-world     # Test Docker installation
docker ps                  # List running containers
docker images              # List downloaded images
```

---

*"The best time to plant a tree was 20 years ago. The second best time is now."* - Let's plant your container knowledge tree today! 🌱
