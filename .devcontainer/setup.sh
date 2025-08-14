#!/bin/bash

# Docker & Red Hat Enterprise Linux Learning Environment Setup Script
# This script configures Ubuntu to simulate a Red Hat Enterprise Linux learning environment

set -e

echo "🚀 Setting up your Docker & Red Hat Enterprise Linux Learning Environment..."

# Update system packages
echo "📦 Updating system packages..."
apt-get update -y

# Install essential packages (Ubuntu equivalents of RHEL tools)
echo "🔧 Installing essential tools..."
apt-get install -y \
    curl \
    wget \
    vim \
    nano \
    tree \
    htop \
    net-tools \
    dnsutils \
    telnet \
    netcat \
    jq \
    unzip \
    tar \
    man-pages \
    manpages-dev \
    build-essential \
    software-properties-common \
    apt-transport-https \
    ca-certificates \
    gnupg \
    lsb-release

# Create dnf alias to simulate RHEL package management
echo "📦 Setting up RHEL-compatible package management simulation..."
cat > /usr/local/bin/dnf << 'EOF'
#!/bin/bash
# DNF simulation script for learning purposes
# This provides dnf-like commands using apt-get underneath

case "$1" in
    "install")
        shift
        echo "🔧 Installing packages with dnf (simulated)..."
        apt-get install -y "$@"
        ;;
    "update")
        echo "📦 Updating package lists with dnf (simulated)..."
        apt-get update
        ;;
    "upgrade")
        echo "⬆️ Upgrading packages with dnf (simulated)..."
        apt-get upgrade -y
        ;;
    "remove")
        shift
        echo "🗑️ Removing packages with dnf (simulated)..."
        apt-get remove -y "$@"
        ;;
    "search")
        shift
        echo "🔍 Searching packages with dnf (simulated)..."
        apt-cache search "$@"
        ;;
    "list")
        if [ "$2" = "installed" ]; then
            echo "📋 Listing installed packages with dnf (simulated)..."
            dpkg -l
        else
            echo "📋 Listing available packages with dnf (simulated)..."
            apt list
        fi
        ;;
    "groupinstall")
        shift
        if [ "$1" = "Development Tools" ] || [ "$1" = '"Development Tools"' ]; then
            echo "🛠️ Installing Development Tools group with dnf (simulated)..."
            apt-get install -y build-essential gcc g++ make autoconf automake libtool pkg-config
        else
            echo "📦 Group install for $1 (simulated)"
        fi
        ;;
    "clean")
        echo "🧹 Cleaning package cache with dnf (simulated)..."
        apt-get clean
        ;;
    "--version")
        echo "dnf simulation script for RHEL learning environment"
        echo "Underlying package manager: $(apt-get --version | head -1)"
        ;;
    *)
        echo "DNF Learning Simulation - Available commands:"
        echo "  dnf install <package>     - Install packages"
        echo "  dnf update               - Update package lists"
        echo "  dnf upgrade              - Upgrade packages"
        echo "  dnf remove <package>     - Remove packages"
        echo "  dnf search <term>        - Search packages"
        echo "  dnf list [installed]     - List packages"
        echo "  dnf groupinstall <group> - Install package groups"
        echo "  dnf clean                - Clean package cache"
        echo ""
        echo "Note: This simulates RHEL's dnf using Ubuntu's apt-get for learning purposes"
        ;;
esac
EOF

chmod +x /usr/local/bin/dnf

# Create systemctl simulation for learning (basic commands)
echo "⚙️ Setting up systemctl simulation for learning..."
cat > /usr/local/bin/systemctl-learn << 'EOF'
#!/bin/bash
# SystemD simulation for learning purposes
# This provides basic systemctl-like commands for educational use

case "$1" in
    "start")
        if [ "$2" = "docker" ]; then
            echo "🐳 Starting Docker service..."
            service docker start
        else
            echo "▶️ Starting service: $2 (simulated for learning)"
        fi
        ;;
    "stop")
        if [ "$2" = "docker" ]; then
            echo "🛑 Stopping Docker service..."
            service docker stop
        else
            echo "⏹️ Stopping service: $2 (simulated for learning)"
        fi
        ;;
    "enable")
        if [ "$2" = "docker" ]; then
            echo "✅ Enabling Docker service to start on boot..."
            update-rc.d docker enable
        else
            echo "✅ Enabling service: $2 (simulated for learning)"
        fi
        ;;
    "disable")
        echo "❌ Disabling service: $2 (simulated for learning)"
        ;;
    "status")
        if [ "$2" = "docker" ]; then
            service docker status
        else
            echo "📊 Status of service: $2 (simulated for learning)"
            echo "   Active: active (running) since $(date)"
        fi
        ;;
    "restart")
        if [ "$2" = "docker" ]; then
            echo "🔄 Restarting Docker service..."
            service docker restart
        else
            echo "🔄 Restarting service: $2 (simulated for learning)"
        fi
        ;;
    *)
        echo "SystemCtl Learning Simulation - Available commands:"
        echo "  systemctl start <service>    - Start a service"
        echo "  systemctl stop <service>     - Stop a service"
        echo "  systemctl enable <service>   - Enable service on boot"
        echo "  systemctl disable <service>  - Disable service on boot"
        echo "  systemctl status <service>   - Show service status"
        echo "  systemctl restart <service>  - Restart a service"
        echo ""
        echo "Note: This simulates RHEL's systemctl for learning purposes"
        ;;
esac
EOF

chmod +x /usr/local/bin/systemctl-learn

# Create alias for systemctl to use our learning version
echo "alias systemctl='systemctl-learn'" >> /etc/bash.bashrc

# Set up helpful aliases for Windows users
echo "⚡ Setting up helpful aliases..."
cat >> /home/vscode/.zshrc << 'EOF'

# Windows-to-Linux command aliases for easier transition
alias dir='ls -la'
alias cls='clear'
alias type='cat'
alias copy='cp'
alias move='mv'
alias del='rm'
alias md='mkdir'
alias rd='rmdir'

# Docker shortcuts
alias d='docker'
alias dc='docker-compose'
alias dps='docker ps'
alias di='docker images'
alias dex='docker exec -it'
alias dlog='docker logs'

# System shortcuts
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias ..='cd ..'
alias ...='cd ../..'
alias grep='grep --color=auto'

# Git shortcuts
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git log --oneline'

# Show current directory in a Windows-familiar way
alias pwd='echo "Current directory: $(pwd)"'

# Network tools
alias ports='netstat -tuln'
alias myip='curl -s ifconfig.me'

# RHEL simulation aliases
alias systemctl='systemctl-learn'

EOF

# Also add aliases to bashrc for consistency
cat >> /home/vscode/.bashrc << 'EOF'

# Windows-to-Linux command aliases for easier transition
alias dir='ls -la'
alias cls='clear'
alias type='cat'
alias copy='cp'
alias move='mv'
alias del='rm'
alias md='mkdir'
alias rd='rmdir'

# Docker shortcuts
alias d='docker'
alias dc='docker-compose'
alias dps='docker ps'
alias di='docker images'
alias dex='docker exec -it'
alias dlog='docker logs'

# System shortcuts
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias ..='cd ..'
alias ...='cd ../..'
alias grep='grep --color=auto'

# Git shortcuts
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git log --oneline'

# Show current directory in a Windows-familiar way
alias pwd='echo "Current directory: $(pwd)"'

# Network tools
alias ports='netstat -tuln'
alias myip='curl -s ifconfig.me'

# RHEL simulation aliases
alias systemctl='systemctl-learn'

EOF

# Create a welcome message
echo "🎉 Creating welcome message..."
cat > /home/vscode/.welcome << 'EOF'
🐳 Welcome to your Docker & Red Hat Enterprise Linux Learning Environment! 🐳

You're now in a learning environment that simulates Red Hat Enterprise Linux!

This environment provides RHEL-compatible commands for learning:
  📦 dnf          - Package management (simulated)
  ⚙️ systemctl    - Service management (simulated)
  🐳 docker       - Container management (real Docker!)

Quick Start Commands:
  📁 dir          - List files (like Windows dir command)
  🐳 docker --version - Check Docker installation
  📖 cat README.md - View the course overview
  🚀 cd modules/01-rocky-linux-basics - Start Module 1

Windows → Linux Command Cheat Sheet:
  dir → ls -la (or just use 'dir' - we've got you covered!)
  cls → clear
  type → cat
  copy → cp
  move → mv

Your container journey starts now! 🌟

Note: This environment simulates RHEL commands for learning purposes.
All Docker functionality is real and production-ready!
EOF

# Add welcome message to shell startup
echo 'cat ~/.welcome' >> /home/vscode/.zshrc
echo 'cat ~/.welcome' >> /home/vscode/.bashrc

# Create a helpful motd (message of the day)
cat > /etc/motd << 'EOF'

 ____             _              _     _                  
|  _ \  ___   ___| | _____ _ __ | |   (_)_ __  _   ___  __
| | | |/ _ \ / __| |/ / _ \ '__|| |   | | '_ \| | | \ \/ /
| |_| | (_) | (__|   <  __/ |   | |___| | | | | |_| |>  < 
|____/ \___/ \___|_|\_\___|_|   |_____|_|_| |_|\__,_/_/\_\

🐳 Docker & Red Hat Enterprise Linux Learning Environment 🐳
Ready for your container adventure!

This environment simulates RHEL commands for educational purposes.
EOF

# Set proper ownership
chown -R vscode:vscode /home/vscode

# Configure zsh as default shell for vscode user (manual approach)
echo "🐚 Configuring zsh as default shell..."
if command -v zsh >/dev/null 2>&1; then
    # Change shell for vscode user
    chsh -s /usr/bin/zsh vscode
    
    echo "✅ Zsh configured as default shell for vscode user"
else
    echo "⚠️  Zsh not found, skipping shell configuration"
fi

# Create course directory structure
echo "📚 Setting up course structure..."
mkdir -p /workspaces/docker-linux-training/{modules,shared-resources,final-project,instructor-notes}
mkdir -p /workspaces/docker-linux-training/shared-resources/{cheat-sheets,troubleshooting-guides,sample-apps,diagrams}

# Create a system info script that shows RHEL-like information
cat > /usr/local/bin/sysinfo << 'EOF'
#!/bin/bash
echo "🖥️  System Information"
echo "===================="
echo "Learning Environment: Red Hat Enterprise Linux Simulation"
echo "Base System: $(lsb_release -d | cut -f2)"
echo "Kernel: $(uname -r)"
echo "Docker: $(docker --version 2>/dev/null || echo 'Not running')"
echo "Package Manager: dnf (simulated)"
echo "Service Manager: systemctl (simulated)"
echo "User: $(whoami)"
echo "Working Directory: $(pwd)"
echo "Disk Usage: $(df -h / | tail -1 | awk '{print $5}') used"
echo "Memory: $(free -h | grep Mem | awk '{print $3 "/" $2}')"
echo "===================="
echo "Note: This environment simulates RHEL for learning purposes"
EOF

chmod +x /usr/local/bin/sysinfo

# Start Docker service
echo "🐳 Starting Docker service..."
service docker start

# Add vscode user to docker group
usermod -aG docker vscode

# Create a test script to verify everything works
cat > /home/vscode/test-environment.sh << 'EOF'
#!/bin/bash
echo "🧪 Testing your RHEL learning environment..."
echo ""

# Test basic commands
echo "✅ Testing basic Linux commands..."
ls -la > /dev/null && echo "  ✓ ls command works"
pwd > /dev/null && echo "  ✓ pwd command works"
whoami > /dev/null && echo "  ✓ whoami command works"

# Test RHEL simulation commands
echo ""
echo "📦 Testing RHEL simulation commands..."
dnf --version > /dev/null && echo "  ✓ dnf command available (simulated)"
systemctl --help > /dev/null 2>&1 && echo "  ✓ systemctl command available (simulated)"

# Test Docker
echo ""
echo "🐳 Testing Docker..."
if docker --version > /dev/null 2>&1; then
    echo "  ✓ Docker is installed: $(docker --version)"
    if docker ps > /dev/null 2>&1; then
        echo "  ✓ Docker daemon is running"
        echo "  ✓ Docker permissions are correct"
    else
        echo "  ⚠️  Docker daemon might not be running or permissions need adjustment"
    fi
else
    echo "  ❌ Docker is not installed or not in PATH"
fi

# Test network connectivity
echo ""
echo "🌐 Testing network connectivity..."
if ping -c 1 google.com > /dev/null 2>&1; then
    echo "  ✓ Internet connectivity works"
else
    echo "  ⚠️  Internet connectivity issues"
fi

echo ""
echo "🎉 Environment test complete!"
echo "If you see mostly ✓ marks, you're ready to start learning!"
echo ""
echo "📚 Learning Environment Notes:"
echo "  • This simulates RHEL commands for educational purposes"
echo "  • Docker functionality is real and production-ready"
echo "  • Use 'dnf' and 'systemctl' commands as you would in RHEL"
echo ""
echo "Next steps:"
echo "1. Run 'cd modules/01-rocky-linux-basics' to start Module 1"
echo "2. Read the README.md in each module"
echo "3. Have fun learning containers!"
EOF

chmod +x /home/vscode/test-environment.sh
chown vscode:vscode /home/vscode/test-environment.sh

echo ""
echo "🎉 Setup complete! Your Docker & Red Hat Enterprise Linux learning environment is ready!"
echo ""
echo "🚀 Quick start:"
echo "  - Run 'test-environment.sh' to verify everything works"
echo "  - Run 'sysinfo' to see system information"
echo "  - Start with Module 1: cd modules/01-rocky-linux-basics"
echo ""
echo "📚 Learning Notes:"
echo "  - This environment simulates RHEL commands for educational purposes"
echo "  - Use 'dnf' and 'systemctl' as you would in a real RHEL system"
echo "  - Docker functionality is real and production-ready"
echo ""
echo "Happy learning! 🐳"
