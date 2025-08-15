# 🗺️ Lesson 1: The Great File System Adventure

*"Where did my C: drive go?!"*

Welcome to your first Linux lesson! If you're staring at your terminal wondering where all the familiar Windows drive letters went, you're in the right place. Let's explore the Linux file system together - it's actually more logical than Windows once you get the hang of it!

## 🎯 What You'll Learn

- How Linux organizes files (spoiler: no drive letters!)
- Essential navigation commands
- The difference between absolute and relative paths
- How to find your way around like a Linux pro

## 🌳 The Linux File System Tree

In Windows, you're used to seeing drives like `C:\`, `D:\`, etc. Linux takes a different approach - everything starts from a single root directory called `/` (forward slash, not backslash!).

Think of it like this:
- **Windows**: Multiple trees (C:, D:, E:) in a forest
- **Linux**: One giant tree with everything branching from the root `/`

### The Linux Directory Structure

```
/                    (Root - the top of everything)
├── home/           (User home directories - like C:\Users)
│   └── vscode/     (Your personal folder)
├── etc/            (Configuration files - like Windows Registry)
├── var/            (Variable data - logs, databases)
├── usr/            (User programs - like C:\Program Files)
├── bin/            (Essential system programs)
├── tmp/            (Temporary files)
└── opt/            (Optional software)
```

## 🧭 Navigation Commands

Let's learn the essential commands to move around:

### `pwd` - "Print Working Directory"
*Windows equivalent: Shows current folder path*

```bash
pwd
```

This shows you exactly where you are. Think of it as your GPS coordinates in the file system.

**Try it now:**
```bash
pwd
```

You should see something like `/workspaces/docker-rocky-learning`

### `ls` - "List"
*Windows equivalent: `dir`*

```bash
ls          # Basic file listing
ls -l       # Long format (detailed info)
ls -la      # Long format including hidden files
ls -lh      # Long format with human-readable file sizes
```

**Try these commands:**
```bash
ls
ls -la
ls -lh
```

**🎯 Pro Tip:** Remember our Windows-friendly alias? You can just type `dir` and it works like `ls -la`!

### `cd` - "Change Directory"
*Windows equivalent: `cd` (same command!)*

```bash
cd /path/to/directory    # Go to specific directory
cd ~                     # Go to your home directory
cd ..                    # Go up one directory
cd -                     # Go back to previous directory
cd                       # Go to home directory (shortcut)
```

## 🛤️ Understanding Paths

### Absolute Paths
Start with `/` and give the complete path from root:
```bash
cd /home/vscode
cd /workspaces/docker-rocky-learning
```

### Relative Paths
Start from where you currently are:
```bash
cd modules                    # Go to modules folder from current location
cd ../shared-resources       # Go up one level, then into shared-resources
cd ../../                    # Go up two levels
```

### Special Path Shortcuts
```bash
~        # Your home directory (/home/vscode)
.        # Current directory
..       # Parent directory (one level up)
-        # Previous directory
```

## 🔍 Exploring Your Environment

Let's take a tour of your new Linux home!

### Your Home Directory
```bash
cd ~
pwd
ls -la
```

You should see files like `.zshrc`, `.welcome`, and others. Files starting with `.` are hidden (like Windows hidden files).

### The Root Directory
```bash
cd /
ls -la
```

This shows you the main system directories. Don't worry - you won't break anything by looking around!

### Back to Your Workspace
```bash
cd /workspaces/docker-rocky-learning
ls -la
```

## 🧪 Lab 1: File System Exploration

Time to practice! Complete these tasks:

### Task 1: Basic Navigation
1. Find out where you currently are:
   ```bash
   pwd
   ```

2. List all files in your current directory:
   ```bash
   ls -la
   ```

3. Go to your home directory:
   ```bash
   cd ~
   pwd
   ```

### Task 2: Directory Hopping
1. From your home directory, navigate to the root:
   ```bash
   cd /
   ls
   ```

2. Go to the `/etc` directory and see what's there:
   ```bash
   cd /etc
   ls | head -20    # Show first 20 items
   ```

3. Return to your workspace:
   ```bash
   cd /workspaces/docker-rocky-learning
   ```

### Task 3: Relative Path Practice
1. From your workspace, go to the modules directory:
   ```bash
   cd modules
   ls
   ```

2. Go up one level and then into shared-resources:
   ```bash
   cd ../shared-resources
   ls
   ```

3. Go back to the workspace root:
   ```bash
   cd ..
   pwd
   ```

### Task 4: Hidden Files Hunt
1. Go to your home directory:
   ```bash
   cd ~
   ```

2. List all files including hidden ones:
   ```bash
   ls -la
   ```

3. Look at your welcome message:
   ```bash
   cat .welcome
   ```

## 🎯 Quick Challenge

Can you navigate to your home directory using three different methods? Try:
1. `cd ~`
2. `cd /home/vscode`
3. `cd` (with no arguments)

Verify you're in the right place each time with `pwd`.

## 🤔 Common "Oops!" Moments

### "I'm lost! Where am I?"
**Solution:** Use `pwd` to see your current location, then `cd ~` to go home.

### "I can't find my files!"
**Solution:** Use `ls -la` to see all files including hidden ones.

### "I went to the wrong directory!"
**Solution:** Use `cd -` to go back to your previous directory.

### "This path doesn't work!"
**Solution:** Check if you're using forward slashes `/` not backslashes `\`.

## 🏆 Knowledge Check

Before moving on, make sure you can:
- [ ] Use `pwd` to see where you are
- [ ] Use `ls -la` to list all files
- [ ] Navigate using both absolute and relative paths
- [ ] Use `cd ~` to go home
- [ ] Use `cd ..` to go up one directory
- [ ] Find and view hidden files

## 🚀 What's Next?

Great job! You've mastered Linux navigation. In the next lesson, we'll learn about [Command Translation Dictionary](02-command-translations.md) where we'll map all your favorite Windows commands to their Linux equivalents.

## 📝 Quick Reference Card

```bash
# Where am I?
pwd

# What's here?
ls -la          # or just 'dir' (our Windows-friendly alias)

# Go places
cd /path        # Absolute path
cd folder       # Relative path
cd ~            # Home directory
cd ..           # Up one level
cd -            # Previous directory

# Special directories
~               # Home directory
.               # Current directory
..              # Parent directory
/               # Root directory
```

---

*"Getting lost is just another way of saying 'going exploring'."* - Keep exploring, and you'll be a Linux navigator in no time! 🧭
