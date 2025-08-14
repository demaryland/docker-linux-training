#!/bin/bash

# Docker & Rocky Linux Learning Environment Setup Script
# This script configures the Rocky Linux 9 environment for the learning course

set -e

echo "🚀 Setting up your Docker & Rocky Linux Learning Environment..."

# Update system packages
echo "📦 Updating system packages..."
dnf update -y

# Install essential packages
echo "🔧 Installing essential tools..."
dnf install -y \
    curl \
    wget \
    vim \
    nano \
    tree \
    htop \
    net-tools \
    bind-utils \
    telnet \
    nc \
    jq \
    unzip \
    tar \
    which \
    man-pages \
    man-db

# Install development tools
echo "🛠️ Installing development tools..."
dnf groupinstall -y "Development Tools"

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

EOF

# Create a welcome message
echo "🎉 Creating welcome message..."
cat > /home/vscode/.welcome << 'EOF'
🐳 Welcome to your Docker & Rocky Linux Learning Environment! 🐳

You're now running Rocky Linux 9 with Docker ready to go!

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
EOF

# Add welcome message to shell startup
echo 'cat ~/.welcome' >> /home/vscode/.zshrc

# Create a helpful motd (message of the day)
cat > /etc/motd << 'EOF'

 ____             _              _     _                  
|  _ \  ___   ___| | _____ _ __ | |   (_)_ __  _   ___  __
| | | |/ _ \ / __| |/ / _ \ '__|| |   | | '_ \| | | \ \/ /
| |_| | (_) | (__|   <  __/ |   | |___| | | | | |_| |>  < 
|____/ \___/ \___|_|\_\___|_|   |_____|_|_| |_|\__,_/_/\_\

🐳 Docker & Rocky Linux Learning Environment 🐳
Ready for your container adventure!

EOF

# Set proper ownership
chown -R vscode:vscode /home/vscode

# Configure zsh as default shell for vscode user (manual approach)
echo "🐚 Configuring zsh as default shell..."
if command -v zsh >/dev/null 2>&1; then
    # Install util-linux-user to get chsh command
    dnf install -y util-linux-user
    
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

# Create a quick system info script
cat > /usr/local/bin/sysinfo << 'EOF'
#!/bin/bash
echo "🖥️  System Information"
echo "===================="
echo "OS: $(cat /etc/rocky-release)"
echo "Kernel: $(uname -r)"
echo "Docker: $(docker --version 2>/dev/null || echo 'Not running')"
echo "User: $(whoami)"
echo "Working Directory: $(pwd)"
echo "Disk Usage: $(df -h / | tail -1 | awk '{print $5}') used"
echo "Memory: $(free -h | grep Mem | awk '{print $3 "/" $2}')"
echo "===================="
EOF

chmod +x /usr/local/bin/sysinfo

# Start Docker service
echo "🐳 Starting Docker service..."
systemctl start docker
systemctl enable docker

# Add vscode user to docker group
usermod -aG docker vscode

# Create a test script to verify everything works
cat > /home/vscode/test-environment.sh << 'EOF'
#!/bin/bash
echo "🧪 Testing your learning environment..."
echo ""

# Test basic commands
echo "✅ Testing basic Linux commands..."
ls -la > /dev/null && echo "  ✓ ls command works"
pwd > /dev/null && echo "  ✓ pwd command works"
whoami > /dev/null && echo "  ✓ whoami command works"

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
echo "Next steps:"
echo "1. Run 'cd modules/01-rocky-linux-basics' to start Module 1"
echo "2. Read the README.md in each module"
echo "3. Have fun learning containers!"
EOF

chmod +x /home/vscode/test-environment.sh
chown vscode:vscode /home/vscode/test-environment.sh

echo ""
echo "🎉 Setup complete! Your Docker & Rocky Linux learning environment is ready!"
echo ""
echo "🚀 Quick start:"
echo "  - Run 'test-environment.sh' to verify everything works"
echo "  - Run 'sysinfo' to see system information"
echo "  - Start with Module 1: cd modules/01-rocky-linux-basics"
echo ""
echo "Happy learning! 🐳"
