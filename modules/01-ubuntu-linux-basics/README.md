# 🚀 Module 1: Welcome to Ubuntu Linux - Your New Command Center

*"Trading PowerShell for Bash - It's not so scary!"*

Welcome to your first step in the container journey! If you're coming from a Windows background, you might be feeling a bit like you've landed on an alien planet. Don't worry - by the end of this module, you'll be navigating Ubuntu Linux like you've been doing it for years, and you'll understand how these skills translate to RHEL-based systems.

## 🎯 Learning Objectives

By the end of this module, you'll be able to:
- Navigate the Linux file system confidently (goodbye C:\ drives!)
- Use essential Linux commands with Windows command equivalents
- Manage files and directories like a pro
- Understand Linux users and permissions
- Install and manage software packages with `apt` (and understand `dnf` for RHEL)
- Customize your terminal environment for maximum productivity
- **Bonus**: Understand key differences between Ubuntu and RHEL systems

## 📚 Module Contents

### 🗺️ [Lesson 1: The Great File System Adventure](lessons/01-file-system-navigation.md)
*"Where did my C: drive go?!"*
- Linux file system structure vs Windows
- Navigation commands: `pwd`, `ls`, `cd`
- Understanding paths: absolute vs relative
- **Lab**: Explore your new Linux home

### 🔧 [Lesson 2: Command Translation Dictionary](lessons/02-command-translations.md)
*"I just want to list files like 'dir' in Windows!"*
- Windows to Linux command mappings
- Essential file operations
- Getting help with `man` pages
- **Lab**: Practice common file operations

### 👤 [Lesson 3: Users, Groups, and the Permission Puzzle](lessons/03-users-permissions.md)
*"Why can't I just be Administrator for everything?"*
- Understanding Linux users and groups
- File permissions explained simply
- The mighty `sudo` command
- **Lab**: Set up your user environment

### 📦 [Lesson 4: Package Management - Your Software Store](lessons/04-package-management.md)
*"Where's the Add/Remove Programs?"*
- Introduction to `apt` package manager (Ubuntu's way)
- Installing, updating, and removing software
- Managing repositories
- **Ubuntu vs RHEL**: How `apt` compares to `dnf`
- **Lab**: Install useful tools for your toolkit

### ⚡ [Lesson 5: Terminal Customization - Make It Yours](lessons/05-terminal-customization.md)
*"Can I make this terminal less scary?"*
- Customizing your shell prompt
- Creating useful aliases
- Terminal shortcuts and productivity tips
- **Lab**: Build your personalized command center

## 🔄 Ubuntu vs RHEL Learning Integration

Throughout this module, you'll see these helpful comparisons:

### Package Management
| Task | Ubuntu | RHEL/CentOS |
|------|--------|-------------|
| Install package | `sudo apt install package` | `sudo dnf install package` |
| Search packages | `apt search keyword` | `dnf search keyword` |
| Update system | `sudo apt update && sudo apt upgrade` | `sudo dnf update` |
| Remove package | `sudo apt remove package` | `sudo dnf remove package` |

### Key Similarities
- **File system structure**: Identical on both
- **User management**: Same commands (`useradd`, `usermod`, etc.)
- **Permissions**: Same system (`chmod`, `chown`, etc.)
- **Service management**: Both use `systemctl`

### When You'll Encounter Each
- **Ubuntu**: Cloud deployments, development environments, Docker hosts
- **RHEL/CentOS**: Enterprise environments, long-term support needs

## 🎮 Module Challenge: "The Linux Scavenger Hunt"

Put your new skills to the test with a fun scavenger hunt that will have you exploring the system, finding hidden files, and using various commands to solve puzzles. It's like a treasure hunt, but with more `ls` commands!

## 🏆 Achievement Unlocked

Complete this module to earn your **"Linux Navigator"** badge! 🧭

## 🤔 Discussion Topics

After completing the labs, consider these questions:
1. What surprised you most about the Ubuntu file system compared to Windows?
2. Which Linux commands do you think you'll use most often?
3. How do you think understanding Ubuntu will help with containers?
4. What are the key differences you noticed between Ubuntu and RHEL approaches?

## 📖 Quick Reference

### Windows → Linux Command Cheat Sheet
| Windows | Ubuntu/Linux | What it does |
|---------|--------------|--------------|
| `dir` | `ls -la` | List files and directories |
| `cd` | `cd` | Change directory (same!) |
| `cls` | `clear` | Clear screen |
| `type filename` | `cat filename` | Display file contents |
| `copy` | `cp` | Copy files |
| `move` | `mv` | Move/rename files |
| `del` | `rm` | Delete files |
| `md` | `mkdir` | Create directory |
| `rd` | `rmdir` | Remove directory |

### Essential Ubuntu Commands
```bash
# Navigation
pwd                 # Show current directory
ls -la             # List all files with details
cd /path/to/dir    # Change directory
cd ~               # Go to home directory
cd ..              # Go up one directory

# File operations
cat filename       # Display file contents
less filename      # View file page by page
head filename      # Show first 10 lines
tail filename      # Show last 10 lines
find . -name "*.txt"  # Find files by name

# Package management (Ubuntu)
sudo apt update    # Update package lists
sudo apt install pkg  # Install package
apt search keyword # Search packages
sudo apt remove pkg   # Remove package

# System information
whoami            # Show current user
id                # Show user and group IDs
uname -a          # Show system information
df -h             # Show disk usage
free -h           # Show memory usage
```

### RHEL Equivalent Commands
```bash
# Package management (RHEL)
sudo dnf update    # Update packages
sudo dnf install pkg  # Install package
dnf search keyword # Search packages
sudo dnf remove pkg   # Remove package

# Everything else is the same!
```

## 🚀 Ready to Start?

Head over to [Lesson 1: The Great File System Adventure](lessons/01-file-system-navigation.md) and let's begin your Ubuntu Linux journey!

Remember: Every Linux expert was once a Windows user who took their first `ls` command. You've got this! 💪

---

## 🆘 Need Help?

- **Stuck on a command?** Try `man commandname` for help
- **Made a mistake?** Don't worry! Linux is forgiving, and we'll show you how to fix common issues
- **Want to practice more?** Each lesson has extra challenges for when you're feeling confident
- **Curious about RHEL?** Look for the "Ubuntu vs RHEL" boxes throughout the lessons

## 🌟 Why This Approach Works

**Starting with Ubuntu gives you:**
- Clean, beginner-friendly package management
- Excellent documentation and community support
- Wide industry adoption
- Great Docker integration

**Learning RHEL differences prepares you for:**
- Enterprise environments
- Long-term support requirements
- Compliance and security-focused deployments
- Red Hat ecosystem tools

By the end of this module, you'll be comfortable with Ubuntu and ready to adapt to any Linux distribution!

*"The journey of a thousand containers begins with a single `ls` command."* 🐧
