# 🔄 Windows to Linux Command Cheat Sheet

*Your quick reference guide for command translation*

## 📁 File and Directory Operations

| Task | Windows | Linux | Notes |
|------|---------|-------|-------|
| **List files** | `dir` | `ls -la` | Use `dir` alias in our environment |
| **List files (simple)** | `dir /w` | `ls` | Basic listing |
| **List by date** | `dir /od` | `ls -lt` | Newest first |
| **List by size** | `dir /os` | `ls -lS` | Largest first |
| **Recursive list** | `dir /s` | `ls -R` | All subdirectories |
| **Show hidden files** | `dir /ah` | `ls -la` | Files starting with . |

## 📄 File Operations

| Task | Windows | Linux | Notes |
|------|---------|-------|-------|
| **Copy file** | `copy file1 file2` | `cp file1 file2` | Single file |
| **Copy multiple** | `copy *.txt dest\` | `cp *.txt dest/` | Pattern matching |
| **Move/rename** | `move old new` | `mv old new` | Same command for both |
| **Delete file** | `del filename` | `rm filename` | Single file |
| **Delete multiple** | `del *.tmp` | `rm *.tmp` | Pattern matching |
| **Delete forcefully** | `del /f filename` | `rm -f filename` | Force delete |

## 📂 Directory Operations

| Task | Windows | Linux | Notes |
|------|---------|-------|-------|
| **Create directory** | `md dirname` | `mkdir dirname` | Single directory |
| **Create nested** | `md dir1\dir2\dir3` | `mkdir -p dir1/dir2/dir3` | Multiple levels |
| **Remove empty dir** | `rd dirname` | `rmdir dirname` | Must be empty |
| **Remove with contents** | `rd /s dirname` | `rm -rf dirname` | ⚠️ Be careful! |
| **Current directory** | `cd` | `pwd` | Show where you are |

## 👀 File Content Viewing

| Task | Windows | Linux | Notes |
|------|---------|-------|-------|
| **Display file** | `type filename` | `cat filename` | Entire file |
| **Page through file** | `more filename` | `less filename` | Navigate with arrows |
| **First few lines** | N/A | `head filename` | First 10 lines |
| **Last few lines** | N/A | `tail filename` | Last 10 lines |
| **Follow file changes** | N/A | `tail -f filename` | Watch file grow |

## 🖥️ System Information

| Task | Windows | Linux | Notes |
|------|---------|-------|-------|
| **Clear screen** | `cls` | `clear` | Clean terminal |
| **Current user** | `whoami` | `whoami` | Same command! |
| **Computer name** | `hostname` | `hostname` | Same command! |
| **Date and time** | `date` | `date` | Same command! |
| **Network config** | `ipconfig` | `ip addr show` | Show IP addresses |
| **Network config (simple)** | `ipconfig` | `hostname -I` | Just IP addresses |
| **Running processes** | `tasklist` | `ps aux` | All processes |
| **Kill process** | `taskkill /pid 1234` | `kill 1234` | By process ID |

## 🔍 Search and Find

| Task | Windows | Linux | Notes |
|------|---------|-------|-------|
| **Find files** | `dir /s filename` | `find . -name filename` | Search subdirectories |
| **Find by pattern** | `dir /s *.txt` | `find . -name "*.txt"` | Use quotes in Linux |
| **Search in files** | `findstr "text" *.txt` | `grep "text" *.txt` | Search file contents |
| **Search recursively** | `findstr /s "text" *` | `grep -r "text" .` | All subdirectories |

## 🔧 File Permissions (Linux Only)

| Task | Command | Notes |
|------|---------|-------|
| **View permissions** | `ls -la` | First column shows permissions |
| **Change permissions** | `chmod 755 filename` | rwxr-xr-x |
| **Change owner** | `chown user:group filename` | Need sudo for others' files |
| **Make executable** | `chmod +x filename` | Add execute permission |

## 🌐 Network Commands

| Task | Windows | Linux | Notes |
|------|---------|-------|-------|
| **Ping host** | `ping hostname` | `ping hostname` | Same command! |
| **Trace route** | `tracert hostname` | `traceroute hostname` | Path to host |
| **DNS lookup** | `nslookup hostname` | `nslookup hostname` | Same command! |
| **Show connections** | `netstat -an` | `netstat -tuln` | Active connections |
| **Show listening ports** | `netstat -an \| find "LISTEN"` | `netstat -tuln \| grep LISTEN` | Different grep syntax |

## 📦 Package Management (Linux Only)

| Task | Command | Notes |
|------|---------|-------|
| **Update package list** | `dnf check-update` | Check for updates |
| **Install package** | `sudo dnf install packagename` | Need sudo |
| **Remove package** | `sudo dnf remove packagename` | Uninstall |
| **Search packages** | `dnf search keyword` | Find packages |
| **List installed** | `dnf list installed` | All installed packages |

## 🎯 Pro Tips

### Aliases Set Up For You
These Windows commands work in our environment:
```bash
dir     # Same as ls -la
cls     # Same as clear
type    # Same as cat
copy    # Same as cp
move    # Same as mv
del     # Same as rm
md      # Same as mkdir
rd      # Same as rmdir
```

### Useful Linux Shortcuts
```bash
!!      # Repeat last command
!$      # Last argument of previous command
~       # Home directory
.       # Current directory
..      # Parent directory
-       # Previous directory (with cd)
```

### Wildcards
```bash
*       # Match any characters
?       # Match single character
[abc]   # Match a, b, or c
[a-z]   # Match any lowercase letter
[0-9]   # Match any digit
```

### Command History
```bash
history         # Show command history
!123           # Run command number 123 from history
Ctrl+R         # Search command history
Up/Down arrows # Navigate through history
```

## 🆘 Emergency Commands

| Situation | Command | What it does |
|-----------|---------|--------------|
| **I'm lost!** | `pwd` | Show where you are |
| **Go home** | `cd ~` | Go to home directory |
| **Stop running command** | `Ctrl+C` | Cancel current command |
| **Clear screen** | `clear` or `Ctrl+L` | Clean up terminal |
| **Get help** | `man commandname` | Show manual |
| **Exit terminal** | `exit` | Close terminal session |

---

*Keep this cheat sheet handy - even Linux experts refer to documentation!* 📚
