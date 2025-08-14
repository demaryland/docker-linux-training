# 🔧 Lesson 2: Command Translation Dictionary

*"I just want to list files like 'dir' in Windows!"*

Welcome back, Linux explorer! Now that you know how to navigate the file system, let's learn how to actually DO things with files. If you've been thinking "I wish I could just use `dir` like in Windows," good news - we've got you covered with aliases, plus you'll learn the "real" Linux commands too.

## 🎯 What You'll Learn

- Windows to Linux command translations
- Essential file and directory operations
- How to get help when you're stuck
- Text file viewing and editing basics
- System information commands

## 🗺️ The Great Command Translation Guide

### File and Directory Listing

| Windows Command | Linux Command | What It Does | Example |
|----------------|---------------|--------------|---------|
| `dir` | `ls -la` | List files with details | `ls -la` |
| `dir /w` | `ls` | Simple file listing | `ls` |
| `dir *.txt` | `ls *.txt` | List specific file types | `ls *.txt` |
| `dir /s` | `ls -R` | Recursive listing | `ls -R` |

**🎯 Pro Tip:** Remember, you can still use `dir` in our environment - we set up an alias for you!

### File Operations

| Windows Command | Linux Command | What It Does | Example |
|----------------|---------------|--------------|---------|
| `copy file1 file2` | `cp file1 file2` | Copy a file | `cp report.txt backup.txt` |
| `copy *.txt backup\` | `cp *.txt backup/` | Copy multiple files | `cp *.txt backup/` |
| `move file1 file2` | `mv file1 file2` | Move/rename file | `mv oldname.txt newname.txt` |
| `del filename` | `rm filename` | Delete a file | `rm unwanted.txt` |
| `del *.tmp` | `rm *.tmp` | Delete multiple files | `rm *.tmp` |

### Directory Operations

| Windows Command | Linux Command | What It Does | Example |
|----------------|---------------|--------------|---------|
| `md dirname` | `mkdir dirname` | Create directory | `mkdir projects` |
| `rd dirname` | `rmdir dirname` | Remove empty directory | `rmdir empty_folder` |
| `rd /s dirname` | `rm -rf dirname` | Remove directory and contents | `rm -rf old_project` |
| `cd` | `pwd` | Show current directory | `pwd` |

### File Content Viewing

| Windows Command | Linux Command | What It Does | Example |
|----------------|---------------|--------------|---------|
| `type filename` | `cat filename` | Display entire file | `cat config.txt` |
| `more filename` | `less filename` | View file page by page | `less longfile.txt` |
| N/A | `head filename` | Show first 10 lines | `head logfile.txt` |
| N/A | `tail filename` | Show last 10 lines | `tail logfile.txt` |
| N/A | `tail -f filename` | Follow file changes | `tail -f /var/log/messages` |

### System Information

| Windows Command | Linux Command | What It Does | Example |
|----------------|---------------|--------------|---------|
| `cls` | `clear` | Clear screen | `clear` |
| `date` | `date` | Show date/time | `date` |
| `whoami` | `whoami` | Show current user | `whoami` |
| `hostname` | `hostname` | Show computer name | `hostname` |
| `ipconfig` | `ip addr` | Show network info | `ip addr show` |
| `tasklist` | `ps aux` | Show running processes | `ps aux` |

## 🧪 Lab 2: Command Practice Session

Let's practice these commands with real examples!

### Task 1: File Listing Mastery

1. **Basic listing** (try both ways):
   ```bash
   dir          # Windows-style (our alias)
   ls -la       # Linux-style
   ```

2. **List only directories**:
   ```bash
   ls -d */
   ```

3. **List files by size**:
   ```bash
   ls -lh       # Human-readable sizes
   ls -lS       # Sort by size (largest first)
   ```

4. **List files by date**:
   ```bash
   ls -lt       # Sort by modification time (newest first)
   ```

### Task 2: File Operations Practice

1. **Create a test directory and files**:
   ```bash
   mkdir practice
   cd practice
   echo "Hello Linux!" > greeting.txt
   echo "This is a test file" > test.txt
   echo "Another file" > another.txt
   ```

2. **Copy files**:
   ```bash
   cp greeting.txt greeting_backup.txt
   cp *.txt ../backup/    # Copy all .txt files to backup directory
   ```

3. **Move and rename files**:
   ```bash
   mv another.txt renamed.txt
   mv test.txt ../       # Move to parent directory
   ```

4. **View file contents**:
   ```bash
   cat greeting.txt      # Show entire file
   type greeting.txt     # Windows-style (our alias)
   head greeting.txt     # First 10 lines (same as cat for small files)
   ```

### Task 3: Directory Management

1. **Create nested directories**:
   ```bash
   mkdir -p projects/web/html
   mkdir -p projects/web/css
   mkdir -p projects/docs
   ```

2. **View the structure**:
   ```bash
   tree projects         # If tree is installed
   ls -R projects        # Recursive listing
   ```

3. **Navigate and explore**:
   ```bash
   cd projects/web
   pwd
   ls -la
   cd ../../            # Go back up two levels
   ```

### Task 4: System Information Gathering

1. **Basic system info**:
   ```bash
   whoami               # Your username
   hostname             # Computer name
   date                 # Current date and time
   pwd                  # Where you are
   ```

2. **File system information**:
   ```bash
   df -h                # Disk usage (human readable)
   free -h              # Memory usage
   ```

3. **Process information**:
   ```bash
   ps aux | head -10    # First 10 running processes
   ```

## 🔍 Getting Help - The `man` Command

One of the most powerful features in Linux is the built-in help system. When you're stuck, use `man` (manual):

```bash
man ls          # Get help for the ls command
man cp          # Get help for the cp command
man man         # Get help for the man command itself!
```

**Navigation in man pages:**
- `Space` or `Page Down` - Next page
- `Page Up` - Previous page
- `/searchterm` - Search for text
- `q` - Quit

**Try it:**
```bash
man ls
```

Look for the different options like `-l`, `-a`, `-h`, etc.

## 🎯 Advanced File Operations

### Wildcards and Patterns

Linux supports powerful pattern matching:

```bash
ls *.txt         # All files ending in .txt
ls test*         # All files starting with "test"
ls test?.txt     # Files like test1.txt, testa.txt (single character)
ls [abc]*        # Files starting with a, b, or c
```

### File Permissions Quick Look

When you use `ls -la`, you see something like:
```
-rw-r--r-- 1 vscode vscode 1234 Dec 25 10:30 myfile.txt
```

The first part (`-rw-r--r--`) shows permissions:
- First character: file type (`-` = file, `d` = directory)
- Next 3: owner permissions (read, write, execute)
- Next 3: group permissions
- Last 3: everyone else permissions

Don't worry - we'll cover this in detail in Lesson 3!

## 🤔 Common "Oops!" Moments

### "I deleted the wrong file!"
**Prevention:** Use `ls` to check what you're about to delete:
```bash
ls *.txt         # See what files match before deleting
rm *.txt         # Now delete them
```

### "The command didn't work!"
**Solution:** Check your spelling and use `man commandname` for help.

### "I can't find my file!"
**Solution:** Use `find` command:
```bash
find . -name "filename.txt"    # Search current directory and subdirectories
find . -name "*.txt"           # Find all .txt files
```

### "The file is too long to read!"
**Solution:** Use `less` instead of `cat`:
```bash
less longfile.txt    # Navigate with arrow keys, quit with 'q'
```

## 🏆 Knowledge Check

Before moving on, make sure you can:
- [ ] List files using both `ls` and `dir`
- [ ] Copy, move, and delete files
- [ ] Create and remove directories
- [ ] View file contents with `cat` and `less`
- [ ] Use `man` to get help
- [ ] Use wildcards to match multiple files
- [ ] Navigate man pages

## 🎮 Mini Challenge: File Detective

Create this scenario and solve it:

1. Create a directory called `mystery`
2. Create 5 files: `clue1.txt`, `clue2.txt`, `evidence.log`, `suspect.txt`, `solution.md`
3. Put some text in each file using `echo "text" > filename`
4. Use various commands to:
   - List all files
   - Find all `.txt` files
   - Display the contents of all files
   - Copy all clue files to a new `backup` directory

## 🚀 What's Next?

Excellent work! You're becoming fluent in Linux commands. Next up: [Users, Groups, and the Permission Puzzle](03-users-permissions.md) where we'll learn about Linux security and permissions.

## 📝 Quick Reference Card

```bash
# File listing
ls -la          # Detailed listing
ls -lh          # Human-readable sizes
ls *.txt        # Pattern matching

# File operations
cp file1 file2  # Copy
mv file1 file2  # Move/rename
rm file         # Delete
rm -rf dir/     # Delete directory and contents

# Directory operations
mkdir dirname   # Create directory
rmdir dirname   # Remove empty directory
mkdir -p a/b/c  # Create nested directories

# File viewing
cat file        # Show entire file
less file       # Page through file
head file       # First 10 lines
tail file       # Last 10 lines

# Getting help
man command     # Show manual for command
```

---

*"The expert in anything was once a beginner who refused to give up."* - Keep practicing these commands, and they'll become second nature! 💪
