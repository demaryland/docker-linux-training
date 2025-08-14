# ⚡ Lesson 5: Terminal Customization - Make It Yours

*"Can I make this terminal less scary?"*

Absolutely! The terminal doesn't have to be a boring black screen with white text. In this lesson, we'll transform your terminal into a personalized, productive workspace that you'll actually enjoy using. Think of it as decorating your office - but for your command line!

## 🎯 What You'll Learn

- Customizing your shell prompt
- Creating useful aliases and shortcuts
- Setting up environment variables
- Configuring terminal colors and themes
- Productivity tips and tricks
- Making the terminal work the way YOU want

## 🎨 Understanding Your Shell Environment

### What is a Shell?

Your **shell** is the program that interprets your commands. It's like the interface between you and the Linux system.

**Common Shells:**
- **bash** (Bourne Again Shell) - Most common, default on many systems
- **zsh** (Z Shell) - Feature-rich, what we're using in our environment
- **fish** (Friendly Interactive Shell) - Beginner-friendly with great defaults

### Shell Configuration Files

Your shell reads configuration files when it starts:

**For zsh (what we're using):**
- `~/.zshrc` - Main configuration file
- `~/.zsh_history` - Command history

**For bash:**
- `~/.bashrc` - Main configuration file
- `~/.bash_history` - Command history

## 🎭 Customizing Your Prompt

### Understanding the Prompt

Your prompt is the text that appears before your cursor. By default, it might look like:
```
vscode@codespace:~/project$
```

This tells you:
- `vscode` - Your username
- `codespace` - Your hostname
- `~/project` - Current directory
- `$` - You're a regular user (root would show `#`)

### Customizing Your Zsh Prompt

Let's make your prompt more informative and colorful!

**Basic prompt customization:**
```bash
# Edit your .zshrc file
nano ~/.zshrc
```

Add these lines to customize your prompt:
```bash
# Custom prompt with colors and git info
autoload -Uz vcs_info
precmd() { vcs_info }
zstyle ':vcs_info:git:*' formats ' (%b)'
setopt PROMPT_SUBST
PROMPT='%F{green}%n@%m%f:%F{blue}%~%f%F{red}${vcs_info_msg_0_}%f$ '
```

**What this does:**
- `%F{green}%n@%m%f` - Username@hostname in green
- `%F{blue}%~%f` - Current directory in blue
- `%F{red}${vcs_info_msg_0_}%f` - Git branch in red (if in a git repo)
- `$ ` - Dollar sign prompt

## 🚀 Creating Powerful Aliases

### What are Aliases?

Aliases are shortcuts for commands. Instead of typing long commands, you can create short, memorable shortcuts.

### Useful Aliases for Windows Users

We've already set up some Windows-friendly aliases, but let's add more:

```bash
# Edit your .zshrc file
nano ~/.zshrc

# Add these aliases at the end
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# Windows-style commands (already set up, but here for reference)
alias dir='ls -la'
alias cls='clear'
alias type='cat'
alias copy='cp'
alias move='mv'
alias del='rm'

# Git shortcuts
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git log --oneline'

# Docker shortcuts
alias d='docker'
alias dc='docker-compose'
alias dps='docker ps'
alias di='docker images'

# System shortcuts
alias h='history'
alias j='jobs -l'
alias ports='netstat -tuln'
alias myip='curl -s ifconfig.me'

# Safety aliases
alias rm='rm -i'    # Ask before deleting
alias cp='cp -i'    # Ask before overwriting
alias mv='mv -i'    # Ask before overwriting

# Productivity aliases
alias grep='grep --color=auto'
alias mkdir='mkdir -pv'  # Create parent directories and be verbose
alias df='df -h'         # Human readable disk usage
alias du='du -h'         # Human readable directory usage
alias free='free -h'     # Human readable memory usage
```

### Creating Custom Aliases

You can create aliases for your most common tasks:

```bash
# Project shortcuts
alias proj='cd ~/projects'
alias docs='cd ~/Documents'

# Quick edits
alias zshconfig='nano ~/.zshrc'
alias reload='source ~/.zshrc'

# System monitoring
alias cpu='top'
alias mem='free -h'
alias disk='df -h'

# Network tools
alias ping='ping -c 5'  # Only ping 5 times by default
```

## 🌈 Adding Colors and Themes

### Enabling Colors

Make your terminal more colorful and easier to read:

```bash
# Add to ~/.zshrc
export CLICOLOR=1
export LSCOLORS=ExFxBxDxCxegedabagacad

# For ls command colors
alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
```

### Oh My Zsh Themes

Our environment comes with Oh My Zsh pre-installed. You can change themes:

```bash
# Edit ~/.zshrc and change the theme line
ZSH_THEME="robbyrussell"  # Default
# ZSH_THEME="agnoster"    # Popular alternative
# ZSH_THEME="powerlevel10k/powerlevel10k"  # Advanced
```

## 🔧 Environment Variables

### What are Environment Variables?

Environment variables are settings that affect how your shell and programs behave.

### Useful Environment Variables

```bash
# Add to ~/.zshrc

# Set default editor
export EDITOR=nano        # Or vim if you prefer

# Add to PATH (where shell looks for commands)
export PATH="$PATH:$HOME/bin"

# History settings
export HISTSIZE=10000     # Remember more commands
export SAVEHIST=10000
export HISTFILE=~/.zsh_history

# Less pager settings (for man pages)
export LESS='-R'          # Show colors in less
export LESSOPEN='|pygmentize -g %s'  # Syntax highlighting
```

## 🧪 Lab 5: Terminal Customization Workshop

Let's customize your terminal step by step!

### Task 1: Basic Prompt Customization

1. **Backup your current configuration:**
   ```bash
   cp ~/.zshrc ~/.zshrc.backup
   ```

2. **Edit your .zshrc file:**
   ```bash
   nano ~/.zshrc
   ```

3. **Add a custom prompt at the end:**
   ```bash
   # Custom colorful prompt
   PROMPT='%F{cyan}[%D{%H:%M:%S}]%f %F{green}%n@%m%f:%F{blue}%~%f$ '
   ```

4. **Reload your configuration:**
   ```bash
   source ~/.zshrc
   ```

   Your prompt should now show the time in cyan!

### Task 2: Creating Useful Aliases

1. **Add productivity aliases to ~/.zshrc:**
   ```bash
   # Quick navigation
   alias home='cd ~'
   alias root='cd /'
   alias dtop='cd ~/Desktop'
   alias proj='cd ~/projects'
   
   # File operations
   alias ll='ls -alF'
   alias la='ls -A'
   alias l='ls -CF'
   alias tree='tree -C'  # Colorful tree
   
   # System info
   alias sysinfo='echo "=== System Info ===" && uname -a && echo "=== Memory ===" && free -h && echo "=== Disk ===" && df -h'
   ```

2. **Reload and test:**
   ```bash
   source ~/.zshrc
   sysinfo
   ll
   ```

### Task 3: Setting Up Environment Variables

1. **Add useful environment variables:**
   ```bash
   # Add to ~/.zshrc
   export EDITOR=nano
   export HISTSIZE=10000
   export SAVEHIST=10000
   
   # Custom PATH additions
   export PATH="$PATH:$HOME/bin:$HOME/.local/bin"
   
   # Colorful man pages
   export LESS_TERMCAP_mb=$'\e[1;32m'
   export LESS_TERMCAP_md=$'\e[1;32m'
   export LESS_TERMCAP_me=$'\e[0m'
   export LESS_TERMCAP_se=$'\e[0m'
   export LESS_TERMCAP_so=$'\e[01;33m'
   export LESS_TERMCAP_ue=$'\e[0m'
   export LESS_TERMCAP_us=$'\e[1;4;31m'
   ```

2. **Test your changes:**
   ```bash
   source ~/.zshrc
   echo $EDITOR
   man ls  # Should have colorful text
   ```

### Task 4: Creating Custom Functions

Functions are like aliases but more powerful:

1. **Add useful functions to ~/.zshrc:**
   ```bash
   # Create and enter directory
   mkcd() {
       mkdir -p "$1" && cd "$1"
   }
   
   # Extract various archive formats
   extract() {
       if [ -f $1 ] ; then
           case $1 in
               *.tar.bz2)   tar xjf $1     ;;
               *.tar.gz)    tar xzf $1     ;;
               *.bz2)       bunzip2 $1     ;;
               *.rar)       unrar e $1     ;;
               *.gz)        gunzip $1      ;;
               *.tar)       tar xf $1      ;;
               *.tbz2)      tar xjf $1     ;;
               *.tgz)       tar xzf $1     ;;
               *.zip)       unzip $1       ;;
               *.Z)         uncompress $1  ;;
               *.7z)        7z x $1        ;;
               *)     echo "'$1' cannot be extracted via extract()" ;;
           esac
       else
           echo "'$1' is not a valid file"
       fi
   }
   
   # Find files by name
   ff() {
       find . -name "*$1*" -type f
   }
   
   # Find directories by name
   fd() {
       find . -name "*$1*" -type d
   }
   ```

2. **Test your functions:**
   ```bash
   source ~/.zshrc
   mkcd test-directory    # Should create and enter directory
   ff "*.txt"            # Find all .txt files
   ```

## 🎯 Advanced Customization Tips

### Tab Completion

Zsh has powerful tab completion. Enable more features:

```bash
# Add to ~/.zshrc
autoload -U compinit
compinit

# Case insensitive completion
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'

# Menu selection
zstyle ':completion:*' menu select
```

### History Search

Make history search more powerful:

```bash
# Add to ~/.zshrc
# History search with arrow keys
bindkey '^[[A' history-search-backward
bindkey '^[[B' history-search-forward

# Ctrl+R for reverse search (like bash)
bindkey '^R' history-incremental-search-backward
```

### Useful Zsh Options

```bash
# Add to ~/.zshrc
setopt AUTO_CD              # Just type directory name to cd
setopt CORRECT              # Suggest corrections for typos
setopt HIST_IGNORE_DUPS     # Don't save duplicate commands
setopt SHARE_HISTORY        # Share history between terminals
setopt EXTENDED_GLOB        # Enable extended globbing
```

## 🏆 Knowledge Check

Before moving on, make sure you can:
- [ ] Customize your shell prompt
- [ ] Create and use aliases
- [ ] Set environment variables
- [ ] Create custom functions
- [ ] Navigate your configuration files
- [ ] Reload your shell configuration

## 🎯 Final Challenge: Create Your Perfect Terminal

Create a personalized terminal setup with:

1. **A custom prompt** that shows:
   - Current time
   - Username and hostname
   - Current directory
   - Git branch (if in a git repo)

2. **Useful aliases** for:
   - Your most common commands
   - Windows-style commands
   - Docker shortcuts
   - System monitoring

3. **Custom functions** for:
   - Creating and entering directories
   - Finding files
   - System information

4. **Environment variables** for:
   - Your preferred editor
   - Extended history
   - Colorful output

## 🚀 What's Next?

Congratulations! You've completed Module 1 and transformed from a Linux newcomer to someone who can confidently navigate, customize, and manage a Linux system. 

Your next adventure awaits in [Module 2: Meet Docker - Your Application Packaging Superhero](../../02-docker-fundamentals/), where we'll dive into the exciting world of containers!

## 📝 Quick Reference Card

```bash
# Configuration files
~/.zshrc                # Main zsh configuration
~/.bashrc               # Main bash configuration

# Reload configuration
source ~/.zshrc         # Apply changes

# Create aliases
alias shortcut='long command'

# Environment variables
export VARIABLE=value

# Custom functions
function_name() {
    # commands here
}

# Edit configuration
nano ~/.zshrc           # Edit config file
```

## 🌟 Pro Tips

1. **Always backup before major changes:** `cp ~/.zshrc ~/.zshrc.backup`
2. **Test changes incrementally:** Add a few things, test, then add more
3. **Use meaningful alias names:** `alias ll='ls -la'` is better than `alias x='ls -la'`
4. **Document your customizations:** Add comments to remember what things do
5. **Share useful configs:** Your teammates might love your aliases too!

## 🎊 Module 1 Complete!

You've successfully completed your Linux fundamentals! You now have:
- ✅ Linux navigation skills
- ✅ Command-line proficiency  
- ✅ File permission understanding
- ✅ Package management knowledge
- ✅ A customized, productive terminal environment

**Achievement Unlocked: Linux Navigator** 🧭

Ready for containers? Let's go to Module 2! 🐳

---

*"The terminal is not just a tool - it's your command center. Make it yours!"* - Welcome to the world of Linux power users! ⚡
