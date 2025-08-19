#!/usr/bin/env bash
# AKAOIO TERMINAL - UNIVERSAL MOBILE-FIRST INSTALLER
# Smart detection for Termux, Linux, macOS
# Compact, beautiful, no backgrounds

set -e  # Exit on error

# SMART ENVIRONMENT DETECTION
detect_environment() {
    if [ -n "$TERMUX_VERSION" ] || [ -d "/data/data/com.termux" ]; then
        echo "termux"
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if command -v apt-get &> /dev/null; then
            echo "debian"
        elif command -v yum &> /dev/null; then
            echo "redhat"
        elif command -v pacman &> /dev/null; then
            echo "arch"
        else
            echo "linux"
        fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        echo "macos"
    else
        echo "unknown"
    fi
}

# Global environment variable
ENV_TYPE=$(detect_environment)
IS_MOBILE=0
[ "$ENV_TYPE" = "termux" ] && IS_MOBILE=1

# Cleanup function to kill any remaining background processes
cleanup() {
    if [ -n "$LOADING_PID" ] && kill -0 "$LOADING_PID" 2>/dev/null; then
        kill "$LOADING_PID" 2>/dev/null || true
        wait "$LOADING_PID" 2>/dev/null || true
    fi
    
    # Kill any remaining spinner processes
    pkill -f "bash.*spinner" 2>/dev/null || true
    
    exit "${1:-0}"
}

# Set up signal traps for proper cleanup
trap 'cleanup 130' INT
trap 'cleanup 143' TERM
trap 'cleanup $?' EXIT

# Mobile-first colors - high contrast, minimal
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
BACKUP_DIR="$HOME/.terminal-backup-$(date +%Y%m%d-%H%M%S)"

# Check if loading animations are enabled (can be disabled with DISABLE_ANIMATIONS=1 or --no-animations)
ENABLE_ANIMATIONS=1
if [ "${DISABLE_ANIMATIONS:-0}" = "1" ]; then
    ENABLE_ANIMATIONS=0
fi

# Check command line arguments for animation control
for arg in "$@"; do
    case $arg in
        --no-animations|--disable-animations)
            ENABLE_ANIMATIONS=0
            shift
            ;;
        --help|-h)
            echo "AKAOIO Terminal - Cyberpunk Edition Installer"
            echo ""
            echo "Usage: $0 [options]"
            echo ""
            echo "Options:"
            echo "  --no-animations        Disable loading animations"
            echo "  --disable-animations   Same as --no-animations"
            echo "  --help, -h             Show this help message"
            echo ""
            echo "Environment variables:"
            echo "  DISABLE_ANIMATIONS=1   Disable animations (same as --no-animations)"
            echo ""
            exit 0
            ;;
    esac
done

# Check terminal capabilities
check_terminal_support() {
    # Check if terminal supports UTF-8 and cursor positioning
    if [ -z "${TERM:-}" ] || [ "$TERM" = "dumb" ]; then
        return 1
    fi
    
    # Check if we can use tput for cursor control
    if ! command -v tput >/dev/null 2>&1; then
        return 1
    fi
    
    # Test if terminal supports cursor positioning
    if ! tput cup 0 0 >/dev/null 2>&1; then
        return 1
    fi
    
    return 0
}

# Global variable to track loading animation PID
LOADING_PID=""

# Simple loading functions that avoid terminal compatibility issues
show_loading() {
    local text="$1"
    
    # If animations are disabled or terminal doesn't support them, use simple progress
    if [ "$ENABLE_ANIMATIONS" = "0" ] || ! check_terminal_support; then
        printf "${NEON_BLUE}[*] $text...${NC}"
        return 0
    fi
    
    # For compatible terminals, use dots animation instead of spinners
    printf "${NEON_BLUE}[*] $text${NC}"
    
    (
        trap 'exit 0' TERM INT
        local dots=""
        local max_dots=3
        local count=0
        
        while true; do
            printf "\r${NEON_BLUE}[*] $text$dots${NC}   "
            
            count=$((count + 1))
            if [ $count -le $max_dots ]; then
                dots="$dots."
            else
                dots=""
                count=0
            fi
            
            sleep 0.5
        done
    ) &
    
    LOADING_PID=$!
    return 0
}

# Stop loading animation with improved cleanup
stop_loading() {
    local pid="${1:-$LOADING_PID}"
    local text="${2:-}"
    
    # If animations are disabled, just print success
    if [ "$ENABLE_ANIMATIONS" = "0" ] || ! check_terminal_support; then
        printf " ${GREEN}[✓]${NC}\n"
        return 0
    fi
    
    # Kill the background process gracefully
    if [ -n "$pid" ] && kill -0 "$pid" 2>/dev/null; then
        kill "$pid" 2>/dev/null
        wait "$pid" 2>/dev/null || true
    fi
    
    # Clear the line and show success - use more spaces to clear completely
    printf "\r${GREEN}[✓] ${text:-Done}${NC}                    \n"
    
    LOADING_PID=""
}

# Mobile-first banner
print_banner() {
    clear
    echo -e "${CYAN}AKAOIO TERMINAL${NC}"
    echo -e "${BLUE}Mobile-First Edition${NC}"
    echo -e "${GREEN}Environment: $ENV_TYPE${NC}"
    echo ""
    sleep 1
}

# Backup existing configs
backup_configs() {
    echo -e "${BLUE}▸ Backing up configs${NC}"
    
    mkdir -p "$BACKUP_DIR"
    
    # Backup files if they exist
    [ -f "$HOME/.bashrc" ] && cp "$HOME/.bashrc" "$BACKUP_DIR/" 2>/dev/null || true
    [ -f "$HOME/.zshrc" ] && cp "$HOME/.zshrc" "$BACKUP_DIR/" 2>/dev/null || true
    [ -f "$HOME/.p10k.zsh" ] && cp "$HOME/.p10k.zsh" "$BACKUP_DIR/" 2>/dev/null || true
    [ -d "$HOME/.oh-my-zsh" ] && echo "$HOME/.oh-my-zsh" > "$BACKUP_DIR/oh-my-zsh.path" || true
    
    echo -e "${GREEN}  ✓ Backup saved to: $BACKUP_DIR${NC}"
    sleep 1
}

# Smart package installation
install_packages() {
    echo -e "${BLUE}▸ Installing packages for $ENV_TYPE${NC}"
    
    case "$ENV_TYPE" in
        termux)
            pkg update -y > /dev/null 2>&1
            pkg install -y zsh git curl wget nano \
                fzf bat ripgrep fd neofetch htop ncdu \
                python nodejs > /dev/null 2>&1
            ;;
        debian)
            show_loading "Installing packages"
            sudo apt-get update -qq > /dev/null 2>&1
            sudo apt-get install -y -qq zsh git curl wget \
                fzf bat ripgrep fd-find neofetch htop ncdu > /dev/null 2>&1
            stop_loading
            ;;
        macos)
            if ! command -v brew &> /dev/null; then
                /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
            fi
            brew install zsh git curl wget fzf bat ripgrep fd neofetch htop ncdu
            ;;
        *)
            echo -e "${YELLOW}⚠ Unknown environment, trying generic install${NC}"
            ;;
    esac
    
    echo -e "${GREEN}✓ Packages installed${NC}"
    sleep 1
}

# Install Oh My Zsh
install_oh_my_zsh() {
    echo -e "${BLUE}▸ Installing Oh My Zsh${NC}"
    
    if [ -d "$HOME/.oh-my-zsh" ]; then
        echo -e "${YELLOW}  ⚠ Oh My Zsh already installed, skipping...${NC}"
    else
        show_loading "Installing Oh My Zsh"
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended > /dev/null 2>&1
        stop_loading
        echo -e "${GREEN}  ✓ Oh My Zsh installed${NC}"
    fi
    sleep 1
}

# Install Powerlevel10k theme
install_p10k() {
    echo -e "${BLUE}▸ Installing Powerlevel10k${NC}"
    
    P10K_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
    
    if [ -d "$P10K_DIR" ]; then
        echo -e "${YELLOW}  ⚠ Powerlevel10k already installed, updating...${NC}"
        cd "$P10K_DIR" && git pull > /dev/null 2>&1
    else
        show_loading "Cloning Powerlevel10k"
        git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$P10K_DIR" > /dev/null 2>&1
        stop_loading
    fi
    
    echo -e "${GREEN}  ✓ Powerlevel10k installed${NC}"
    sleep 1
}

# Install plugins
install_plugins() {
    echo -e "${BLUE}▸ Installing plugins${NC}"
    
    CUSTOM_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
    
    # Auto-suggestions
    if [ ! -d "$CUSTOM_DIR/plugins/zsh-autosuggestions" ]; then
        show_loading "Installing auto-suggestions"
        git clone https://github.com/zsh-users/zsh-autosuggestions "$CUSTOM_DIR/plugins/zsh-autosuggestions" > /dev/null 2>&1
        stop_loading
    else
        echo -e "${YELLOW}  ⚠ Auto-suggestions already installed${NC}"
    fi
    
    # Syntax highlighting
    if [ ! -d "$CUSTOM_DIR/plugins/zsh-syntax-highlighting" ]; then
        show_loading "Installing syntax highlighting"
        git clone https://github.com/zsh-users/zsh-syntax-highlighting "$CUSTOM_DIR/plugins/zsh-syntax-highlighting" > /dev/null 2>&1
        stop_loading
    else
        echo -e "${YELLOW}  ⚠ Syntax highlighting already installed${NC}"
    fi
    
    # Completions
    if [ ! -d "$CUSTOM_DIR/plugins/zsh-completions" ]; then
        show_loading "Installing enhanced completions"
        git clone https://github.com/zsh-users/zsh-completions "$CUSTOM_DIR/plugins/zsh-completions" > /dev/null 2>&1
        stop_loading
    else
        echo -e "${YELLOW}  ⚠ Completions already installed${NC}"
    fi
    
    # FZF tab completion
    if [ ! -d "$CUSTOM_DIR/plugins/fzf-tab" ]; then
        show_loading "Installing FZF tab completion"
        git clone https://github.com/Aloxaf/fzf-tab "$CUSTOM_DIR/plugins/fzf-tab" > /dev/null 2>&1
        stop_loading
    else
        echo -e "${YELLOW}  ⚠ FZF tab already installed${NC}"
    fi
    
    echo -e "${GREEN}  ✓ All plugins installed${NC}"
    sleep 1
}

# Smart font installation
install_fonts() {
    echo -e "${BLUE}▸ Setting up fonts${NC}"
    
    if [ "$ENV_TYPE" = "termux" ]; then
        echo -e "${YELLOW}  Termux: Install Termux:Styling from F-Droid for fonts${NC}"
    else
        FONT_DIR="$HOME/.local/share/fonts"
        mkdir -p "$FONT_DIR"
        
        if ! fc-list | grep -q "MesloLGS NF" 2>/dev/null; then
            show_loading "Installing fonts"
            wget -q -P "$FONT_DIR" \
                https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Regular.ttf \
                2>/dev/null || true
            
            if command -v fc-cache &> /dev/null; then
                fc-cache -f "$FONT_DIR" > /dev/null 2>&1
            fi
            stop_loading
        fi
    fi
    
    echo -e "${GREEN}✓ Font setup complete${NC}"
    sleep 1
}

# Configure Zsh
configure_zsh() {
    echo -e "${BLUE}▸ Configuring terminal${NC}"
    
    show_loading "Creating ultimate .zshrc configuration"
    
    # Create .zshrc
    cat > "$HOME/.zshrc" << 'ZSHRC'
# AKAOIO TERMINAL - CYBERPUNK ZSH

# Enable Powerlevel10k instant prompt
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Path to Oh My Zsh
export ZSH="$HOME/.oh-my-zsh"

# Theme
ZSH_THEME="powerlevel10k/powerlevel10k"

# Plugins
plugins=(
    git
    zsh-autosuggestions
    zsh-syntax-highlighting
    zsh-completions
    fzf-tab
    sudo
    docker
    docker-compose
    kubectl
    terraform
    aws
    npm
    node
    python
    pip
    golang
    rust
    command-not-found
    colored-man-pages
    extract
    z
    history-substring-search
)

# Plugin settings - Fixed autosuggestions to prevent garbled characters
# SOLUTION: Disable highlighting completely to prevent terminal compatibility issues
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE=""
# Alternative safe options (choose one and comment out the empty one above):
# ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=240"          # Safe gray color
# ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=black,bold"   # Safe black bold
# ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="underline"       # Just underline, no color
ZSH_AUTOSUGGEST_STRATEGY=(history completion)
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20
ZSH_AUTOSUGGEST_USE_ASYNC=true

# Oh My Zsh settings
ENABLE_CORRECTION="true"
COMPLETION_WAITING_DOTS="⏳"
DISABLE_UNTRACKED_FILES_DIRTY="false"
HIST_STAMPS="yyyy-mm-dd"

# Load Oh My Zsh
source $ZSH/oh-my-zsh.sh

# CYBERPUNK ALIASES

# Better ls with exa - Rainbow colors
if command -v exa &> /dev/null; then
    alias ls='exa --color=always --group-directories-first'
    alias ll='exa -alF --color=always --group-directories-first'  
    alias la='exa -a --color=always --group-directories-first'
    alias l='exa -F --color=always --group-directories-first'
    alias lt='exa --tree --color=always --group-directories-first'
else
    alias ls='ls --color=always'
    alias ll='ls -alF --color=always'
    alias la='ls -A --color=always'
    alias l='ls -CF --color=always'
fi

# Beautiful LS_COLORS - Rainbow theme, no backgrounds
export LS_COLORS='di=38;5;51:ln=38;5;198:so=38;5;46:pi=38;5;226:ex=38;5;196:bd=38;5;81:cd=38;5;81:su=38;5;15:sg=38;5;15:tw=38;5;15:ow=38;5;15:*.tar=38;5;201:*.tgz=38;5;201:*.zip=38;5;201:*.gz=38;5;201:*.bz2=38;5;201:*.xz=38;5;201:*.7z=38;5;201:*.rar=38;5;201:*.deb=38;5;201:*.rpm=38;5;201:*.jar=38;5;201:*.jpg=38;5;213:*.jpeg=38;5;213:*.png=38;5;213:*.gif=38;5;213:*.bmp=38;5;213:*.svg=38;5;213:*.tiff=38;5;213:*.ico=38;5;213:*.mp4=38;5;228:*.mov=38;5;228:*.avi=38;5;228:*.mkv=38;5;228:*.webm=38;5;228:*.mp3=38;5;118:*.wav=38;5;118:*.flac=38;5;118:*.aac=38;5;118:*.ogg=38;5;118:*.js=38;5;226:*.jsx=38;5;226:*.ts=38;5;81:*.tsx=38;5;81:*.json=38;5;226:*.css=38;5;213:*.scss=38;5;213:*.html=38;5;196:*.htm=38;5;196:*.xml=38;5;196:*.md=38;5;15:*.txt=38;5;15:*.log=38;5;243:*.py=38;5;81:*.go=38;5;81:*.rs=38;5;196:*.java=38;5;226:*.c=38;5;118:*.cpp=38;5;118:*.h=38;5;118:*.hpp=38;5;118:*.rb=38;5;196:*.php=38;5;81:*.sh=38;5;118:*.yml=38;5;226:*.yaml=38;5;226:*.toml=38;5;226:*.ini=38;5;226:*.conf=38;5;226:*.cfg=38;5;226:'

# EXA colors for rainbow theme - bright and beautiful
export EXA_COLORS='da=38;5;243:di=38;5;51:ex=38;5;196:fi=38;5;15:ln=38;5;198:bd=38;5;81:cd=38;5;81:pi=38;5;226:so=38;5;46:uu=38;5;118:gu=38;5;228:ur=38;5;196:uw=38;5;81:ux=38;5;213:ue=38;5;81:gr=38;5;226:gw=38;5;81:gx=38;5;213:tr=38;5;196:tw=38;5;81:tx=38;5;213:*.js=38;5;226:*.jsx=38;5;226:*.ts=38;5;81:*.tsx=38;5;81:*.json=38;5;226:*.css=38;5;213:*.scss=38;5;213:*.html=38;5;196:*.htm=38;5;196:*.xml=38;5;196:*.md=38;5;15:*.txt=38;5;15:*.log=38;5;243:*.py=38;5;81:*.go=38;5;81:*.rs=38;5;196:*.java=38;5;226:*.c=38;5;118:*.cpp=38;5;118:*.h=38;5;118:*.hpp=38;5;118:'

# Better cat with bat
if command -v bat &> /dev/null; then
    alias cat='bat --style=numbers,changes,grid --theme="Dracula"'
    alias ccat='/bin/cat'
fi

# Navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias ~='cd ~'
alias -- -='cd -'

# Git shortcuts
alias g='git'
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git log --oneline --graph --decorate --all'
alias gd='git diff'
alias gco='git checkout'
alias gb='git branch'
alias gm='git merge'
alias gr='git remote'
alias gf='git fetch'
alias gpl='git pull'
alias gcl='git clone'

# Docker shortcuts
alias d='docker'
alias dc='docker-compose'
alias dps='docker ps'
alias dpsa='docker ps -a'
alias dimg='docker images'
alias drm='docker rm'
alias drmi='docker rmi'
alias dexec='docker exec -it'
alias dlogs='docker logs'

# System shortcuts
alias h='history | grep'
alias j='jobs -l'
alias ports='sudo lsof -iTCP -sTCP:LISTEN -n -P'
alias myip='curl ifconfig.me'
alias reload='source ~/.zshrc && echo "✨ Terminal reloaded!"'
alias path='echo -e ${PATH//:/\\n}'
alias now='date +"%Y-%m-%d %H:%M:%S"'
alias week='date +%V'

# Safety nets
alias rm='rm -iv'
alias cp='cp -iv'
alias mv='mv -iv'
alias mkdir='mkdir -pv'

# Power user
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
alias diff='diff --color=auto'
alias ip='ip --color=auto'
alias wget='wget -c'
alias df='df -H'
alias du='du -ch'
alias free='free -m'
alias top='htop'
alias vim='nvim'

# Fun stuff
alias matrix='cmatrix -B'
alias weather='curl wttr.in'
alias moon='curl wttr.in/Moon'
alias crypto='curl rate.sx'
alias hack='hollywood'
alias parrot='curl parrot.live'

# CYBERPUNK FUNCTIONS

# Create directory and cd into it
mkcd() {
    mkdir -p "$1" && cd "$1"
}

# Extract any archive
extract() {
    if [ -f $1 ]; then
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
            *)           echo "'$1' cannot be extracted" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}

# Find files
ff() {
    find . -type f -iname "*$1*"
}

# Find directories
fd() {
    find . -type d -iname "*$1*"
}

# System info
sysinfo() {
    echo -e "\n\033[38;5;198mSYSTEM INFORMATION\033[0m\n"
    neofetch
}

# Git status for all repos in current directory
git-status-all() {
    for dir in */; do
        if [ -d "$dir/.git" ]; then
            echo -e "\033[38;5;51m▸ $dir\033[0m"
            cd "$dir"
            git status -s
            cd ..
            echo ""
        fi
    done
}

# Backup file with timestamp
backup() {
    cp "$1" "$1.backup-$(date +%Y%m%d-%H%M%S)"
}

# ENVIRONMENT SETUP

# Environment variables
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
export EDITOR='nano'
export VISUAL='nano'
export PAGER='less'
export LESS='-R'

# History
export HISTSIZE=100000
export SAVEHIST=100000
export HISTFILE=~/.zsh_history
setopt EXTENDED_HISTORY
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_VERIFY
setopt INC_APPEND_HISTORY
setopt SHARE_HISTORY

# FZF settings
export FZF_DEFAULT_OPTS="
    --color=fg:#f8f8f2,bg:#282a36,hl:#bd93f9
    --color=fg+:#f8f8f2,bg+:#44475a,hl+:#bd93f9
    --color=info:#ffb86c,prompt:#50fa7b,pointer:#ff79c6
    --color=marker:#ff79c6,spinner:#ffb86c,header:#6272a4
    --height 40%
    --layout=reverse
    --border
    --preview 'bat --style=numbers --color=always --line-range :500 {}'
"

export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'

# Completion settings
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' rehash true
zstyle ':completion:*' accept-exact '*(N)'
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path ~/.zsh/cache
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'exa -1 --color=always $realpath'
zstyle ':fzf-tab:*' switch-group ',' '.'

# Key bindings
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down
bindkey '^[[C' forward-char
bindkey '^[[D' backward-char
bindkey '^[[H' beginning-of-line
bindkey '^[[F' end-of-line
bindkey '^[[3~' delete-char
bindkey '^A' beginning-of-line
bindkey '^E' end-of-line
bindkey '^K' kill-line
bindkey '^R' history-incremental-search-backward
bindkey '^S' history-incremental-search-forward
bindkey '^Y' yank
bindkey '^N' down-line-or-history
bindkey '^P' up-line-or-history

# Auto suggestions key bindings
bindkey '^ ' autosuggest-accept
bindkey '^[[Z' autosuggest-accept

# Load additional configs
[[ -f ~/.fzf.zsh ]] && source ~/.fzf.zsh
[[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh

# Welcome message
if command -v neofetch &> /dev/null; then
    clear
    neofetch
fi

# END OF CYBERPUNK CONFIG
ZSHRC

    stop_loading
    
    # Use mobile-first P10k config
    if [ "$IS_MOBILE" = "1" ]; then
        cp "$SCRIPT_DIR/configs/p10k-mobile.zsh" "$HOME/.p10k.zsh" 2>/dev/null || \
        curl -fsSL https://raw.githubusercontent.com/akaoio/terminal/main/configs/p10k-mobile.zsh -o "$HOME/.p10k.zsh" 2>/dev/null || \
        create_default_p10k_config
    else
        cp "$SCRIPT_DIR/configs/p10k-cyberpunk.zsh" "$HOME/.p10k.zsh" 2>/dev/null || \
        curl -fsSL https://raw.githubusercontent.com/akaoio/terminal/main/configs/p10k-cyberpunk.zsh -o "$HOME/.p10k.zsh" 2>/dev/null || \
        create_default_p10k_config
    fi
    
    echo -e "${GREEN}  ✓ Configuration complete${NC}"
    sleep 1
}

# Mobile-first P10k config
create_default_p10k_config() {
    cat > "$HOME/.p10k.zsh" << 'P10K'
# Ultra Simple One-Line Prompt
# Format: user@host ~/dir (git) $ 

'builtin' 'local' '-a' 'p10k_config_opts'
[[ ! -o 'aliases'         ]] || p10k_config_opts+=('aliases')
[[ ! -o 'sh_glob'         ]] || p10k_config_opts+=('sh_glob')
[[ ! -o 'no_brace_expand' ]] || p10k_config_opts+=('no_brace_expand')
'builtin' 'setopt' 'no_aliases' 'no_sh_glob' 'brace_expand'

() {
  emulate -L zsh -o extended_glob
  unset -m '(POWERLEVEL9K_*|DEFAULT_USER)~POWERLEVEL9K_GITSTATUS_DIR'
  [[ $ZSH_VERSION == (5.<1->*|<6->.*) ]] || return

  # Simple one-line prompt
  typeset -g POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(
    context                 # user@hostname
    dir                     # current directory  
    vcs                     # git status
    prompt_char            # $ 
  )

  typeset -g POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=()

  # Basic settings - ONE LINE, no backgrounds anywhere
  typeset -g POWERLEVEL9K_PROMPT_ON_NEWLINE=false
  typeset -g POWERLEVEL9K_PROMPT_ADD_NEWLINE=false
  typeset -g POWERLEVEL9K_BACKGROUND=                 # global no background
  
  # Rainbow colors - no backgrounds, text only
  typeset -g POWERLEVEL9K_CONTEXT_FOREGROUND=198     # hot pink text
  typeset -g POWERLEVEL9K_CONTEXT_BACKGROUND=        # no background
  typeset -g POWERLEVEL9K_CONTEXT_TEMPLATE='%n@%m'
  
  typeset -g POWERLEVEL9K_DIR_FOREGROUND=226         # bright yellow text
  typeset -g POWERLEVEL9K_DIR_BACKGROUND=            # no background
  typeset -g POWERLEVEL9K_DIR_MAX_LENGTH=30
  
  # Git - rainbow colors, no backgrounds
  typeset -g POWERLEVEL9K_VCS_CLEAN_FOREGROUND=46     # bright green text
  typeset -g POWERLEVEL9K_VCS_CLEAN_BACKGROUND=       # no background
  typeset -g POWERLEVEL9K_VCS_MODIFIED_FOREGROUND=201 # bright magenta text
  typeset -g POWERLEVEL9K_VCS_MODIFIED_BACKGROUND=    # no background
  typeset -g POWERLEVEL9K_VCS_UNTRACKED_FOREGROUND=51 # bright cyan text
  typeset -g POWERLEVEL9K_VCS_UNTRACKED_BACKGROUND=   # no background
  
  # Rainbow prompt character - no background
  typeset -g POWERLEVEL9K_PROMPT_CHAR_BACKGROUND=     # no background
  typeset -g POWERLEVEL9K_PROMPT_CHAR_OK_{VIINS,VICMD,VIVIS,VIOWR}_FOREGROUND=51    # cyan
  typeset -g POWERLEVEL9K_PROMPT_CHAR_ERROR_{VIINS,VICMD,VIVIS,VIOWR}_FOREGROUND=196  # red  
  typeset -g POWERLEVEL9K_PROMPT_CHAR_OK_VIINS_CONTENT_EXPANSION='$'
  typeset -g POWERLEVEL9K_PROMPT_CHAR_ERROR_VIINS_CONTENT_EXPANSION='$'
  typeset -g POWERLEVEL9K_PROMPT_CHAR_LEFT_PROMPT_LAST_SEGMENT_END_SYMBOL=' '
  
  # Separators - compact spacing
  typeset -g POWERLEVEL9K_{LEFT,RIGHT}_SEGMENT_SEPARATOR=' '
  typeset -g POWERLEVEL9K_{LEFT,RIGHT}_SUBSEGMENT_SEPARATOR=' '
  typeset -g POWERLEVEL9K_{LEFT,RIGHT}_{LEFT,RIGHT}_WHITESPACE=

  (( ! $+functions[p10k] )) || p10k reload
}

(( ${#p10k_config_opts} )) && setopt ${p10k_config_opts[@]}
'builtin' 'unset' 'p10k_config_opts'
P10K
}

# Smart shell configuration
set_default_shell() {
    echo -e "${BLUE}▸ Setting default shell${NC}"
    
    if [ "$ENV_TYPE" = "termux" ]; then
        # Termux: add to .bashrc
        if ! grep -q "exec zsh" ~/.bashrc 2>/dev/null; then
            echo "exec zsh" >> ~/.bashrc
        fi
        # Setup storage access
        termux-setup-storage 2>/dev/null || true
    else
        # Other systems: use chsh
        if [ "$SHELL" != "$(which zsh)" ]; then
            if [ "$ENV_TYPE" = "debian" ] || [ "$ENV_TYPE" = "redhat" ]; then
                sudo chsh -s $(which zsh) $USER 2>/dev/null || true
            else
                chsh -s $(which zsh) 2>/dev/null || true
            fi
        fi
    fi
    
    echo -e "${GREEN}✓ Shell configured${NC}"
    sleep 1
}

# Mobile-first completion message
show_complete() {
    clear
    echo -e "${GREEN}✓ SUCCESS!${NC}"
    echo ""
    echo -e "${CYAN}Installation Complete${NC}"
    echo -e "${BLUE}Environment: $ENV_TYPE${NC}"
    echo ""
    echo -e "${CYAN}  Your terminal has been transformed into a CYBERPUNK MASTERPIECE!${NC}"
    echo ""
    echo -e "${NEON_GREEN}  ▸ FEATURES INSTALLED:${NC}"
    echo -e "${WHITE}    • Zsh with Oh-My-Zsh Framework${NC}"
    echo -e "${WHITE}    • Powerlevel10k Theme (Cyberpunk Edition)${NC}"
    echo -e "${WHITE}    • Auto-suggestions & Syntax Highlighting${NC}"
    echo -e "${WHITE}    • FZF Integration with Tab Completion${NC}"
    echo -e "${WHITE}    • Enhanced CLI Tools (bat, exa, ripgrep)${NC}"
    echo -e "${WHITE}    • Nerd Fonts for Icons${NC}"
    echo -e "${WHITE}    • 50+ Useful Aliases & Functions${NC}"
    echo ""
    echo -e "${NEON_PURPLE}  ▸ KEYBOARD SHORTCUTS:${NC}"
    echo -e "${WHITE}    • Tab         → Auto-complete with FZF${NC}"
    echo -e "${WHITE}    • Ctrl+R      → Search command history${NC}"
    echo -e "${WHITE}    • Ctrl+Space  → Accept auto-suggestion${NC}"
    echo -e "${WHITE}    • Ctrl+T      → Find files${NC}"
    echo -e "${WHITE}    • Alt+C       → Navigate directories${NC}"
    echo ""
    echo -e "${NEON_PINK}  ▸ NEXT STEPS:${NC}"
    echo -e "${WHITE}    1. Restart your terminal or run: ${CYAN}zsh${NC}"
    echo -e "${WHITE}    2. Set terminal font to: ${CYAN}MesloLGS NF${NC}"
    echo -e "${WHITE}    3. Customize further: ${CYAN}p10k configure${NC}"
    echo -e "${WHITE}    4. View all aliases: ${CYAN}alias${NC}"
    echo ""
    echo -e "${YELLOW}  ▸ BACKUP LOCATION:${NC}"
    echo -e "${WHITE}    $BACKUP_DIR${NC}"
    echo ""
    echo -e "${NEON_BLUE}═══════════════════════════════════════════════════════════════════════${NC}"
    echo -e "${NEON_GREEN}         Welcome to the future of terminal experience!${NC}"
    echo -e "${NEON_BLUE}═══════════════════════════════════════════════════════════════════════${NC}"
    echo ""
}

# Main installation flow
main() {
    print_banner
    backup_configs
    install_packages
    install_oh_my_zsh
    install_p10k
    install_plugins
    install_fonts
    configure_zsh
    set_default_shell
    show_complete
}

# Run main function
main

# Start new shell
echo -e "${CYAN}Starting new Zsh shell in 3 seconds...${NC}"
sleep 3
exec zsh -l