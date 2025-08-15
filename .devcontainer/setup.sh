#!/bin/bash

# Docker & Ubuntu Linux Learning Environment Setup Script
# This script configures Ubuntu for Docker and Linux learning

set -e

echo "🚀 Setting up your Docker & Ubuntu Linux Learning Environment..."

# Update system packages
echo "📦 Updating system packages..."
apt-get update -y

# Install essential packages for Docker and Linux learning
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
    lsb-release \
    git \
    zip \
    less \
    grep \
    sed \
    awk

# Set up helpful aliases for Windows users transitioning to Linux
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

# Ubuntu package management shortcuts
alias install='sudo apt install'
alias search='apt search'
alias update='sudo apt update'
alias upgrade='sudo apt upgrade'
alias remove='sudo apt remove'

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

# Ubuntu package management shortcuts
alias install='sudo apt install'
alias search='apt search'
alias update='sudo apt update'
alias upgrade='sudo apt upgrade'
alias remove='sudo apt remove'

EOF

# Create a welcome message
echo "🎉 Creating welcome message..."
cat > /home/vscode/.welcome << 'EOF'
🐳 Welcome to your Docker & Ubuntu Linux Learning Environment! 🐳

You're now in an Ubuntu Linux environment ready for Docker learning!

This environment provides:
  📦 apt           - Ubuntu package management
  ⚙️ systemctl     - Service management
  🐳 docker        - Container management
  🐧 Ubuntu 22.04  - Modern Linux distribution

Quick Start Commands:
  📁 dir           - List files (Windows-style alias)
  🐳 docker --version - Check Docker installation
  📖 cat README.md - View the course overview
  🚀 cd modules/01-ubuntu-linux-basics - Start Module 1

Windows → Linux Command Cheat Sheet:
  dir → ls -la (or just use 'dir' - we've got you covered!)
  cls → clear
  type → cat
  copy → cp
  move → mv

Ubuntu Package Management:
  apt search <package>    - Search for packages
  sudo apt install <pkg> - Install packages
  sudo apt update        - Update package lists
  sudo apt upgrade       - Upgrade packages
  sudo apt remove <pkg>  - Remove packages

Your container journey starts now! 🌟

This course will teach you Ubuntu Linux fundamentals and show you
how concepts differ in RHEL-based systems like CentOS and Rocky Linux.
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

🐳 Docker & Ubuntu Linux Learning Environment 🐳
Ready for your container adventure!

Learn Ubuntu fundamentals with RHEL comparisons throughout!
EOF

# Set proper ownership
chown -R vscode:vscode /home/vscode

# Configure zsh as default shell for vscode user
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

# Create a system info script
cat > /usr/local/bin/sysinfo << 'EOF'
#!/bin/bash
echo "🖥️  System Information"
echo "===================="
echo "Distribution: $(lsb_release -d | cut -f2)"
echo "Kernel: $(uname -r)"
echo "Architecture: $(uname -m)"
echo "Docker: $(docker --version 2>/dev/null || echo 'Not running')"
echo "Package Manager: apt (Advanced Package Tool)"
echo "Service Manager: systemctl (systemd)"
echo "User: $(whoami)"
echo "Working Directory: $(pwd)"
echo "Disk Usage: $(df -h / | tail -1 | awk '{print $5}') used"
echo "Memory: $(free -h | grep Mem | awk '{print $3 "/" $2}')"
echo "===================="
echo "Ubuntu vs RHEL Quick Reference:"
echo "  Ubuntu: apt install    | RHEL: dnf install"
echo "  Ubuntu: apt search     | RHEL: dnf search"
echo "  Ubuntu: systemctl      | RHEL: systemctl (same!)"
echo "  Ubuntu: .deb packages  | RHEL: .rpm packages"
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
echo "🧪 Testing your Ubuntu Linux learning environment..."
echo ""

# Test basic commands
echo "✅ Testing basic Linux commands..."
ls -la > /dev/null && echo "  ✓ ls command works"
pwd > /dev/null && echo "  ✓ pwd command works"
whoami > /dev/null && echo "  ✓ whoami command works"

# Test Ubuntu package management
echo ""
echo "📦 Testing Ubuntu package management..."
apt --version > /dev/null && echo "  ✓ apt command available"
apt list --installed > /dev/null 2>&1 && echo "  ✓ apt package listing works"

# Test system management
echo ""
echo "⚙️ Testing system management..."
systemctl --version > /dev/null 2>&1 && echo "  ✓ systemctl command available"

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
echo "  • This is a real Ubuntu 22.04 environment"
echo "  • Docker functionality is production-ready"
echo "  • Course includes Ubuntu vs RHEL comparisons"
echo ""
echo "Next steps:"
echo "1. Run 'cd modules/01-ubuntu-linux-basics' to start Module 1"
echo "2. Read the README.md in each module"
echo "3. Have fun learning containers on Linux!"
EOF

chmod +x /home/vscode/test-environment.sh
chown vscode:vscode /home/vscode/test-environment.sh

# Create Ubuntu vs RHEL comparison reference
cat > /home/vscode/ubuntu-vs-rhel.md << 'EOF'
# Ubuntu vs RHEL Quick Reference

## Package Management
| Task | Ubuntu | RHEL/CentOS |
|------|--------|-------------|
| Install package | `sudo apt install package` | `sudo dnf install package` |
| Search packages | `apt search keyword` | `dnf search keyword` |
| Update lists | `sudo apt update` | `dnf check-update` |
| Upgrade system | `sudo apt upgrade` | `sudo dnf upgrade` |
| Remove package | `sudo apt remove package` | `sudo dnf remove package` |
| List installed | `apt list --installed` | `dnf list installed` |

## File Locations
| Purpose | Ubuntu | RHEL/CentOS |
|---------|--------|-------------|
| Config files | `/etc/` | `/etc/` (same) |
| Log files | `/var/log/` | `/var/log/` (same) |
| User homes | `/home/` | `/home/` (same) |
| Temp files | `/tmp/` | `/tmp/` (same) |

## Service Management
Both use systemctl (same commands):
- `sudo systemctl start service`
- `sudo systemctl stop service`
- `sudo systemctl enable service`
- `sudo systemctl status service`

## Key Differences
- **Package format**: Ubuntu uses .deb, RHEL uses .rpm
- **Package manager**: Ubuntu uses apt, RHEL uses dnf/yum
- **Release cycle**: Ubuntu LTS every 2 years, RHEL major every 3-4 years
- **Default shell**: Both use bash by default
- **File systems**: Both support ext4, xfs, etc.
EOF

chown vscode:vscode /home/vscode/ubuntu-vs-rhel.md

echo ""
echo "🎉 Setup complete! Your Docker & Ubuntu Linux learning environment is ready!"
echo ""
echo "🚀 Quick start:"
echo "  - Run 'test-environment.sh' to verify everything works"
echo "  - Run 'sysinfo' to see system information"
echo "  - View 'ubuntu-vs-rhel.md' for quick comparisons"
echo "  - Start with Module 1: cd modules/01-ubuntu-linux-basics"
echo ""
echo "📚 Learning Notes:"
echo "  - This is a real Ubuntu environment for authentic learning"
echo "  - Course includes comparisons with RHEL-based systems"
echo "  - Docker functionality is production-ready"
echo ""
echo "Happy learning! 🐳"
