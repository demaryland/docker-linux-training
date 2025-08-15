# 🔄 Windows to Linux Command Cheat Sheet

*Your quick reference guide for command translation*

## 📁 File and Directory Operations

| Task | Windows | Linux (Ubuntu & RHEL) | Notes |
|------|---------|----------------------|-------|
| **List files** | `dir` | `ls -la` | Use `dir` alias in our environment |
| **List files (simple)** | `dir /w` | `ls` | Basic listing |
| **List by date** | `dir /od` | `ls -lt` | Newest first |
| **List by size** | `dir /os` | `ls -lS` | Largest first |
| **Recursive list** | `dir /s` | `ls -R` | All subdirectories |
| **Show hidden files** | `dir /ah` | `ls -la` | Files starting with . |

## 📄 File Operations

| Task | Windows | Linux (Ubuntu & RHEL) | Notes |
|------|---------|----------------------|-------|
| **Copy file** | `copy file1 file2` | `cp file1 file2` | Single file |
| **Copy multiple** | `copy *.txt dest\` | `cp *.txt dest/` | Pattern matching |
| **Move/rename** | `move old new` | `mv old new` | Same command for both |
| **Delete file** | `del filename` | `rm filename` | Single file |
| **Delete multiple** | `del *.tmp` | `rm *.tmp` | Pattern matching |
| **Delete forcefully** | `del /f filename` | `rm -f filename` | Force delete |

## 📂 Directory Operations

| Task | Windows | Linux (Ubuntu & RHEL) | Notes |
|------|---------|----------------------|-------|
| **Create directory** | `md dirname` | `mkdir dirname` | Single directory |
| **Create nested** | `md dir1\dir2\dir3` | `mkdir -p dir1/dir2/dir3` | Multiple levels |
| **Remove empty dir** | `rd dirname` | `rmdir dirname` | Must be empty |
| **Remove with contents** | `rd /s dirname` | `rm -rf dirname` | ⚠️ Be careful! |
| **Current directory** | `cd` | `pwd` | Show where you are |

## 👀 File Content Viewing

| Task | Windows | Linux (Ubuntu & RHEL) | Notes |
|------|---------|----------------------|-------|
| **Display file** | `type filename` | `cat filename` | Entire file |
| **Page through file** | `more filename` | `less filename` | Navigate with arrows |
| **First few lines** | N/A | `head filename` | First 10 lines |
| **Last few lines** | N/A | `tail filename` | Last 10 lines |
| **Follow file changes** | N/A | `tail -f filename` | Watch file grow |

## 🖥️ System Information

| Task | Windows | Linux (Ubuntu & RHEL) | Notes |
|------|---------|----------------------|-------|
| **Clear screen** | `cls` | `clear` | Clean terminal |
| **Current user** | `whoami` | `whoami` | Same command! |
| **Computer name** | `hostname` | `hostname` | Same command! |
| **Date and time** | `date` | `date` | Same command! |
| **Network config** | `ipconfig` | `ip addr show` | Show IP addresses |
| **Network config (simple)** | `ipconfig` | `hostname -I` | Just IP addresses |
| **Running processes** | `tasklist` | `ps aux` | All processes |
| **Kill process** | `taskkill /pid 1234` | `kill 1234` | By process ID |

## 🔍 Search and Find

| Task | Windows | Linux (Ubuntu & RHEL) | Notes |
|------|---------|----------------------|-------|
| **Find files** | `dir /s filename` | `find . -name filename` | Search subdirectories |
| **Find by pattern** | `dir /s *.txt` | `find . -name "*.txt"` | Use quotes in Linux |
| **Search in files** | `findstr "text" *.txt` | `grep "text" *.txt` | Search file contents |
| **Search recursively** | `findstr /s "text" *` | `grep -r "text" .` | All subdirectories |

## 📦 Package Management - The Big Difference!

This is where Ubuntu and RHEL differ significantly:

### Ubuntu (Debian-based) Commands
| Task | Ubuntu Command | Notes |
|------|----------------|-------|
| **Update package lists** | `sudo apt update` | Refresh available packages |
| **Install package** | `sudo apt install package` | Install software |
| **Search packages** | `apt search keyword` | Find packages |
| **Remove package** | `sudo apt remove package` | Uninstall software |
| **Upgrade system** | `sudo apt upgrade` | Update all packages |
| **List installed** | `apt list --installed` | Show installed packages |
| **Package info** | `apt show package` | Detailed package info |
| **Clean cache** | `sudo apt clean` | Free up disk space |

### RHEL (Red Hat-based) Commands
| Task | RHEL Command | Notes |
|------|--------------|-------|
| **Update packages** | `sudo dnf update` | Update and upgrade |
| **Install package** | `sudo dnf install package` | Install software |
| **Search packages** | `dnf search keyword` | Find packages |
| **Remove package** | `sudo dnf remove package` | Uninstall software |
| **List installed** | `dnf list installed` | Show installed packages |
| **Package info** | `dnf info package` | Detailed package info |
| **Clean cache** | `dnf clean all` | Free up disk space |
| **Package groups** | `dnf groupinstall "Development Tools"` | Install related packages |

## 🔧 File Permissions (Linux Only)

| Task | Command | Notes |
|------|---------|-------|
| **View permissions** | `ls -la` | First column shows permissions |
| **Change permissions** | `chmod 755 filename` | rwxr-xr-x |
| **Change owner** | `chown user:group filename` | Need sudo for others' files |
| **Make executable** | `chmod +x filename` | Add execute permission |

## 🌐 Network Commands

| Task | Windows | Linux (Ubuntu & RHEL) | Notes |
|------|---------|----------------------|-------|
| **Ping host** | `ping hostname` | `ping hostname` | Same command! |
| **Trace route** | `tracert hostname` | `traceroute hostname` | Path to host |
| **DNS lookup** | `nslookup hostname` | `nslookup hostname` | Same command! |
| **Show connections** | `netstat -an` | `netstat -tuln` | Active connections |
| **Show listening ports** | `netstat -an \| find "LISTEN"` | `netstat -tuln \| grep LISTEN` | Different grep syntax |

## 🐳 Docker Commands (Identical on Ubuntu & RHEL!)

| Task | Command | Notes |
|------|---------|-------|
| **Check version** | `docker --version` | Same everywhere! |
| **List containers** | `docker ps` | Running containers |
| **List all containers** | `docker ps -a` | Including stopped |
| **List images** | `docker images` | Downloaded images |
| **Run container** | `docker run image` | Start new container |
| **Stop container** | `docker stop container_id` | Graceful stop |
| **Remove container** | `docker rm container_id` | Delete container |
| **Remove image** | `docker rmi image_id` | Delete image |

## 🎯 Pro Tips

### Aliases Set Up For You
These Windows commands work in our Ubuntu environment:
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

### Useful Linux Shortcuts (Ubuntu & RHEL)
```bash
!!      # Repeat last command
!$      # Last argument of previous command
~       # Home directory
.       # Current directory
..      # Parent directory
-       # Previous directory (with cd)
```

### Wildcards (Ubuntu & RHEL)
```bash
*       # Match any characters
?       # Match single character
[abc]   # Match a, b, or c
[a-z]   # Match any lowercase letter
[0-9]   # Match any digit
```

### Command History (Ubuntu & RHEL)
```bash
history         # Show command history
!123           # Run command number 123 from history
Ctrl+R         # Search command history
Up/Down arrows # Navigate through history
```

## 🔄 Ubuntu vs RHEL Quick Comparison

### What's the Same
- **File operations**: All `ls`, `cp`, `mv`, `rm` commands identical
- **Directory navigation**: `cd`, `pwd`, `mkdir` work the same
- **Text processing**: `cat`, `grep`, `sed`, `awk` identical
- **Process management**: `ps`, `kill`, `top` work the same
- **Network tools**: `ping`, `wget`, `curl` identical
- **Docker commands**: 100% identical!
- **Service management**: `systemctl` commands identical

### What's Different
- **Package manager**: `apt` (Ubuntu) vs `dnf` (RHEL)
- **Package format**: `.deb` (Ubuntu) vs `.rpm` (RHEL)
- **Default repositories**: Different software sources
- **Some system paths**: Minor differences in config locations

### When You'll Encounter Each
- **Ubuntu**: Cloud deployments, development, personal servers
- **RHEL/CentOS**: Enterprise environments, long-term support

## 🆘 Emergency Commands

| Situation | Command | What it does |
|-----------|---------|--------------|
| **I'm lost!** | `pwd` | Show where you are |
| **Go home** | `cd ~` | Go to home directory |
| **Stop running command** | `Ctrl+C` | Cancel current command |
| **Clear screen** | `clear` or `Ctrl+L` | Clean up terminal |
| **Get help** | `man commandname` | Show manual |
| **Exit terminal** | `exit` | Close terminal session |

## 📚 Learning Path Recommendations

### Start Here (Ubuntu Focus)
1. **Master basic file operations** - `ls`, `cd`, `cp`, `mv`
2. **Learn Ubuntu package management** - `apt` commands
3. **Practice Docker commands** - Same on all platforms!
4. **Understand permissions** - `chmod`, `chown`

### Expand Your Skills (RHEL Awareness)
1. **Learn RHEL package management** - `dnf` commands
2. **Understand the differences** - When to use which distribution
3. **Practice on both** - Skills transfer easily

### Advanced Topics (Both Platforms)
1. **Shell scripting** - Bash works identically
2. **System administration** - `systemctl`, logs, monitoring
3. **Container orchestration** - Kubernetes, Docker Compose

---

## 🌟 Key Takeaways

1. **Most Linux commands are identical** across Ubuntu and RHEL
2. **Package management is the main difference** - `apt` vs `dnf`
3. **Docker commands are 100% identical** on both platforms
4. **Learn Ubuntu first** - easier for beginners, widely used
5. **RHEL skills transfer easily** - same core concepts
6. **Windows aliases help** - use familiar commands while learning

*Keep this cheat sheet handy - even Linux experts refer to documentation!* 📚

### 🎓 Your Learning Journey

**Phase 1**: Master Ubuntu basics with Windows command aliases
**Phase 2**: Learn native Linux commands and concepts  
**Phase 3**: Understand RHEL differences for enterprise readiness
**Phase 4**: Apply skills to Docker and containerization

You're building skills that work across the entire Linux ecosystem! 🚀
