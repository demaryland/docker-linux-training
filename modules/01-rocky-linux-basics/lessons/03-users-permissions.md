# 👤 Lesson 3: Users, Groups, and the Permission Puzzle

*"Why can't I just be Administrator for everything?"*

Welcome to one of the most important concepts in Linux security! If you're coming from Windows where you might have been used to running as Administrator, Linux takes a different approach. Don't worry - once you understand the logic, you'll appreciate how much more secure and organized it is.

## 🎯 What You'll Learn

- Understanding Linux users and groups
- How file permissions work (and why they matter)
- The mighty `sudo` command and when to use it
- Setting up your user environment properly
- Best practices for permission management

## 👥 Users and Groups in Linux

### The Multi-User Philosophy

Linux was designed from the ground up to be a multi-user system. Even if you're the only person using your computer, Linux still thinks in terms of multiple users with different privileges.

**Key Concepts:**
- **Root user**: The superuser (like Administrator in Windows)
- **Regular users**: Limited privileges for safety
- **Groups**: Collections of users with shared permissions
- **Service users**: Special users for running services

### Who Am I?

Let's start by figuring out who you are in the system:

```bash
whoami          # Shows your current username
id              # Shows your user ID and group memberships
groups          # Shows all groups you belong to
```

**Try it now:**
```bash
whoami
id
groups
```

You should see something like:
```
vscode
uid=1000(vscode) gid=1000(vscode) groups=1000(vscode),4(adm),20(dialout),24(cdrom),25(floppy),27(sudo),29(audio),30(dip),44(video),46(plugdev),117(netdev),999(docker)
```

## 🔐 Understanding File Permissions

### The Permission System

Every file and directory in Linux has three types of permissions for three different categories of users:

**Permission Types:**
- **r** (read): Can view the file content or list directory contents
- **w** (write): Can modify the file or create/delete files in directory
- **x** (execute): Can run the file as a program or enter the directory

**User Categories:**
- **Owner** (user): The person who owns the file
- **Group**: Users who belong to the file's group
- **Others**: Everyone else on the system

### Reading Permission Strings

When you run `ls -la`, you see something like this:
```
-rw-r--r-- 1 vscode vscode 1234 Dec 25 10:30 myfile.txt
drwxr-xr-x 2 vscode vscode 4096 Dec 25 10:30 mydir
```

Let's break down that first part:

```
-rw-r--r--
│└┬┘└┬┘└┬┘
│ │  │  └── Others permissions (r--)
│ │  └───── Group permissions (r--)
│ └──────── Owner permissions (rw-)
└─────────── File type (- = file, d = directory)
```

**Translation:**
- Owner can read and write (rw-)
- Group can only read (r--)
- Others can only read (r--)

### Common Permission Patterns

| Permission | Numeric | Meaning |
|------------|---------|---------|
| `rwx` | 7 | Read, write, execute |
| `rw-` | 6 | Read and write |
| `r-x` | 5 | Read and execute |
| `r--` | 4 | Read only |
| `-wx` | 3 | Write and execute |
| `-w-` | 2 | Write only |
| `--x` | 1 | Execute only |
| `---` | 0 | No permissions |

## 🛠️ Managing Permissions

### Changing File Permissions with `chmod`

The `chmod` command changes file permissions. You can use it in two ways:

**Symbolic Method (easier to understand):**
```bash
chmod u+x filename      # Add execute permission for user (owner)
chmod g-w filename      # Remove write permission for group
chmod o+r filename      # Add read permission for others
chmod a+r filename      # Add read permission for all (user, group, others)
```

**Numeric Method (more precise):**
```bash
chmod 755 filename      # rwxr-xr-x (common for executables)
chmod 644 filename      # rw-r--r-- (common for files)
chmod 600 filename      # rw------- (private file)
chmod 777 filename      # rwxrwxrwx (everyone can do everything - usually not recommended!)
```

### Changing File Ownership with `chown`

```bash
chown user:group filename       # Change owner and group
chown user filename            # Change only owner
chown :group filename          # Change only group
```

**Note:** You usually need `sudo` to change ownership of files you don't own.

## 🦸 The Mighty `sudo` Command

### What is `sudo`?

`sudo` stands for "Super User DO" - it lets you run commands as another user (usually root) temporarily.

**Windows Equivalent:** Like right-clicking and selecting "Run as Administrator"

### When to Use `sudo`

Use `sudo` when you need to:
- Install or remove software
- Modify system files
- Change system settings
- Manage services
- Access files owned by other users

**Examples:**
```bash
sudo dnf install htop           # Install software
sudo systemctl start docker    # Start a system service
sudo chown root:root /etc/hosts # Change ownership of system file
```

### `sudo` Best Practices

✅ **DO:**
- Use `sudo` for specific commands that need elevated privileges
- Understand what a command does before running it with `sudo`
- Use your regular user account for daily work

❌ **DON'T:**
- Run `sudo su` to become root permanently
- Use `sudo` for commands that don't need it
- Share your password or sudo access

## 🧪 Lab 3: Permission Management Practice

Let's practice with real examples!

### Task 1: Exploring Your Environment

1. **Check your current user and groups:**
   ```bash
   whoami
   id
   groups
   ```

2. **Look at file permissions in your home directory:**
   ```bash
   cd ~
   ls -la
   ```

3. **Check permissions on system directories:**
   ```bash
   ls -la /etc | head -10
   ls -la /var/log | head -10
   ```

### Task 2: Creating and Managing Files

1. **Create a test directory and files:**
   ```bash
   mkdir ~/permission-test
   cd ~/permission-test
   echo "This is a test file" > testfile.txt
   echo "This is a script" > myscript.sh
   ```

2. **Check the default permissions:**
   ```bash
   ls -la
   ```

3. **Make the script executable:**
   ```bash
   chmod +x myscript.sh
   ls -la
   ```

   Notice how the permissions changed!

### Task 3: Permission Experiments

1. **Create a private file:**
   ```bash
   echo "Secret information" > private.txt
   chmod 600 private.txt
   ls -la private.txt
   ```

2. **Create a read-only file:**
   ```bash
   echo "Read-only content" > readonly.txt
   chmod 444 readonly.txt
   ls -la readonly.txt
   ```

3. **Try to modify the read-only file:**
   ```bash
   echo "More content" >> readonly.txt
   ```
   
   You should get a permission denied error!

4. **Make it writable again:**
   ```bash
   chmod 644 readonly.txt
   echo "More content" >> readonly.txt
   cat readonly.txt
   ```

### Task 4: Using `sudo` Safely

1. **Try to access a system file without sudo:**
   ```bash
   cat /etc/shadow
   ```
   
   You should get a permission denied error.

2. **Use sudo to view system information:**
   ```bash
   sudo cat /etc/passwd | head -5
   ```

3. **Check what sudo privileges you have:**
   ```bash
   sudo -l
   ```

## 🤔 Common Permission Scenarios

### "I can't run my script!"
**Problem:** Created a script but getting "Permission denied"
**Solution:** Make it executable with `chmod +x scriptname.sh`

### "I can't modify this file!"
**Problem:** File is read-only or owned by someone else
**Solutions:**
- Check permissions: `ls -la filename`
- Make writable: `chmod +w filename`
- If owned by root: `sudo chmod +w filename`

### "I accidentally made a file unreadable!"
**Problem:** Used `chmod 000 filename` and now can't access it
**Solution:** `chmod 644 filename` to restore normal permissions

### "I need to share files with my team"
**Problem:** Other users can't access your files
**Solution:** 
```bash
chmod 755 directory/        # Others can read and enter directory
chmod 644 directory/*       # Others can read files
```

## 🏆 Knowledge Check

Before moving on, make sure you can:
- [ ] Explain the difference between user, group, and other permissions
- [ ] Read permission strings like `rwxr-xr-x`
- [ ] Use `chmod` to change file permissions
- [ ] Understand when to use `sudo`
- [ ] Create files with specific permissions
- [ ] Troubleshoot common permission problems

## 🎯 Quick Challenge

Create a directory structure for a project with these requirements:
1. A `project` directory that others can read and enter
2. A `private` subdirectory that only you can access
3. A `shared` subdirectory that your group can read and write
4. A script file that everyone can execute

**Solution:**
```bash
mkdir project
chmod 755 project

mkdir project/private
chmod 700 project/private

mkdir project/shared
chmod 775 project/shared

echo '#!/bin/bash\necho "Hello from script!"' > project/hello.sh
chmod 755 project/hello.sh
```

## 🚀 What's Next?

Great job! You now understand Linux permissions - one of the most important security concepts. In the next lesson, [Package Management - Your Software Store](04-package-management.md), we'll learn how to install and manage software using the `dnf` command.

## 📝 Quick Reference Card

```bash
# Check user information
whoami                  # Current username
id                      # User and group IDs
groups                  # Group memberships

# View permissions
ls -la                  # List files with permissions
ls -ld directory/       # Show directory permissions

# Change permissions
chmod +x file           # Make executable
chmod 644 file          # rw-r--r--
chmod 755 file          # rwxr-xr-x
chmod 700 file          # rwx------ (private)

# Change ownership (usually needs sudo)
chown user:group file   # Change owner and group
sudo chown root file    # Change owner to root

# Use elevated privileges
sudo command            # Run command as root
sudo -l                 # List sudo privileges
```

---

*"With great power comes great responsibility."* - Now you understand Linux permissions, use them wisely! 🔐
