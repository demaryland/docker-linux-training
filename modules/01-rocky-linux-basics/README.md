# 🚀 Module 1: Welcome to Rocky Linux - Your New Command Center

*"Trading PowerShell for Bash - It's not so scary!"*

Welcome to your first step in the container journey! If you're coming from a Windows background, you might be feeling a bit like you've landed on an alien planet. Don't worry - by the end of this module, you'll be navigating Rocky Linux like you've been doing it for years.

## 🎯 Learning Objectives

By the end of this module, you'll be able to:
- Navigate the Linux file system confidently (goodbye C:\ drives!)
- Use essential Linux commands with Windows command equivalents
- Manage files and directories like a pro
- Understand Linux users and permissions
- Install and manage software packages with `dnf`
- Customize your terminal environment for maximum productivity

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
- Introduction to `dnf` package manager
- Installing, updating, and removing software
- Managing repositories
- **Lab**: Install useful tools for your toolkit

### ⚡ [Lesson 5: Terminal Customization - Make It Yours](lessons/05-terminal-customization.md)
*"Can I make this terminal less scary?"*
- Customizing your shell prompt
- Creating useful aliases
- Terminal shortcuts and productivity tips
- **Lab**: Build your personalized command center

## 🎮 Module Challenge: "The Linux Scavenger Hunt"

Put your new skills to the test with a fun scavenger hunt that will have you exploring the system, finding hidden files, and using various commands to solve puzzles. It's like a treasure hunt, but with more `ls` commands!

## 🏆 Achievement Unlocked

Complete this module to earn your **"Linux Navigator"** badge! 🧭

## 🤔 Discussion Topics

After completing the labs, consider these questions:
1. What surprised you most about the Linux file system compared to Windows?
2. Which Linux commands do you think you'll use most often?
3. How do you think understanding Linux will help with containers?

## 📖 Quick Reference

### Windows → Linux Command Cheat Sheet
| Windows | Linux | What it does |
|---------|-------|--------------|
| `dir` | `ls -la` | List files and directories |
| `cd` | `cd` | Change directory (same!) |
| `cls` | `clear` | Clear screen |
| `type filename` | `cat filename` | Display file contents |
| `copy` | `cp` | Copy files |
| `move` | `mv` | Move/rename files |
| `del` | `rm` | Delete files |
| `md` | `mkdir` | Create directory |
| `rd` | `rmdir` | Remove directory |

### Essential Linux Commands
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

# System information
whoami            # Show current user
id                # Show user and group IDs
uname -a          # Show system information
df -h             # Show disk usage
free -h           # Show memory usage
```

## 🚀 Ready to Start?

Head over to [Lesson 1: The Great File System Adventure](lessons/01-file-system-navigation.md) and let's begin your Linux journey!

Remember: Every Linux expert was once a Windows user who took their first `ls` command. You've got this! 💪

---

## 🆘 Need Help?

- **Stuck on a command?** Try `man commandname` for help
- **Made a mistake?** Don't worry! Linux is forgiving, and we'll show you how to fix common issues
- **Want to practice more?** Each lesson has extra challenges for when you're feeling confident

*"The journey of a thousand containers begins with a single `ls` command."* 🐧
