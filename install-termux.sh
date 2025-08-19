#!/data/data/com.termux/files/usr/bin/bash

# AKAOIO TERMINAL - TERMUX EDITION
# Modified installation script for Termux

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

BACKUP_DIR="$HOME/.terminal-backup-$(date +%Y%m%d-%H%M%S)"

echo -e "${CYAN}AKAOIO TERMINAL - TERMUX EDITION${NC}"
echo ""

# Backup
echo -e "${BLUE}▸ Backing up existing configs...${NC}"
mkdir -p "$BACKUP_DIR"
[ -f "$HOME/.bashrc" ] && cp "$HOME/.bashrc" "$BACKUP_DIR/"
[ -f "$HOME/.zshrc" ] && cp "$HOME/.zshrc" "$BACKUP_DIR/"
echo -e "${GREEN}✓ Backup saved${NC}"

# Update and install packages
echo -e "${BLUE}▸ Installing packages...${NC}"
pkg update -y
pkg install -y zsh git curl wget nano \
    fzf bat ripgrep fd neofetch htop ncdu \
    python nodejs ruby golang rust

# Install Oh My Zsh
echo -e "${BLUE}▸ Installing Oh My Zsh...${NC}"
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

# Install Powerlevel10k
echo -e "${BLUE}▸ Installing Powerlevel10k...${NC}"
P10K_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
if [ ! -d "$P10K_DIR" ]; then
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$P10K_DIR"
fi

# Install plugins
echo -e "${BLUE}▸ Installing plugins...${NC}"
CUSTOM_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

[ ! -d "$CUSTOM_DIR/plugins/zsh-autosuggestions" ] && \
    git clone https://github.com/zsh-users/zsh-autosuggestions "$CUSTOM_DIR/plugins/zsh-autosuggestions"

[ ! -d "$CUSTOM_DIR/plugins/zsh-syntax-highlighting" ] && \
    git clone https://github.com/zsh-users/zsh-syntax-highlighting "$CUSTOM_DIR/plugins/zsh-syntax-highlighting"

[ ! -d "$CUSTOM_DIR/plugins/zsh-completions" ] && \
    git clone https://github.com/zsh-users/zsh-completions "$CUSTOM_DIR/plugins/zsh-completions"

# Configure Zsh (simplified for Termux)
echo -e "${BLUE}▸ Configuring Zsh...${NC}"
cat > "$HOME/.zshrc" << 'ZSHRC'
# TERMUX CYBERPUNK ZSH

# Enable instant prompt
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"

plugins=(
    git
    zsh-autosuggestions
    zsh-syntax-highlighting
    zsh-completions
    command-not-found
    colored-man-pages
    extract
)

source $ZSH/oh-my-zsh.sh

# Termux-specific settings
export LANG=en_US.UTF-8
export TERM=xterm-256color

# Aliases (Termux compatible)
alias ls='ls --color=auto'
alias ll='ls -alF --color=auto'
alias la='ls -A --color=auto'
alias l='ls -CF --color=auto'

# Use bat if available
if command -v bat &> /dev/null; then
    alias cat='bat --theme="Dracula"'
fi

# Navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# Git shortcuts
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git log --oneline --graph'

# Functions
mkcd() { mkdir -p "$1" && cd "$1"; }
backup() { cp "$1" "$1.backup-$(date +%Y%m%d-%H%M%S)"; }

# FZF settings
export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border"

# History
export HISTSIZE=10000
export SAVEHIST=10000
export HISTFILE=~/.zsh_history

# Load P10k
[[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh

# Termux specific - storage access
if [ -d "/storage/emulated/0" ]; then
    alias storage='cd /storage/emulated/0'
    alias downloads='cd /storage/emulated/0/Download'
fi
ZSHRC

# Create simple P10k config
cat > "$HOME/.p10k.zsh" << 'P10K'
# Simple Termux-compatible P10k config
'builtin' 'setopt' 'no_aliases' 'no_sh_glob' 'brace_expand'

() {
  emulate -L zsh -o extended_glob
  
  typeset -g POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(
    dir
    vcs
    prompt_char
  )
  
  typeset -g POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=()
  typeset -g POWERLEVEL9K_PROMPT_ON_NEWLINE=false
  typeset -g POWERLEVEL9K_DIR_FOREGROUND=226
  typeset -g POWERLEVEL9K_VCS_CLEAN_FOREGROUND=46
  typeset -g POWERLEVEL9K_VCS_MODIFIED_FOREGROUND=201
  typeset -g POWERLEVEL9K_PROMPT_CHAR_OK_VIINS_CONTENT_EXPANSION='$'
  
  (( ! $+functions[p10k] )) || p10k reload
}
P10K

echo -e "${GREEN}✓ Configuration complete${NC}"

# Termux-specific setup
echo -e "${BLUE}▸ Setting up Termux...${NC}"

# Request storage permission
termux-setup-storage 2>/dev/null || true

# Install Termux:API if needed
pkg install termux-api 2>/dev/null || true

# Set Zsh as default (Termux way)
if [ -f "$PREFIX/bin/zsh" ]; then
    echo "exec zsh" >> ~/.bashrc
fi

echo ""
echo -e "${GREEN}═══════════════════════════════════════════════════════${NC}"
echo -e "${CYAN}      INSTALLATION COMPLETE FOR TERMUX!${NC}"
echo -e "${GREEN}═══════════════════════════════════════════════════════${NC}"
echo ""
echo -e "${YELLOW}NEXT STEPS:${NC}"
echo -e "1. Restart Termux or run: ${CYAN}zsh${NC}"
echo -e "2. Install a font app like 'Termux:Styling' from F-Droid"
echo -e "3. Customize: ${CYAN}p10k configure${NC}"
echo ""
echo -e "${YELLOW}TERMUX TIPS:${NC}"
echo -e "• Access storage: ${CYAN}termux-setup-storage${NC}"
echo -e "• Install packages: ${CYAN}pkg install <name>${NC}"
echo -e "• Update everything: ${CYAN}pkg upgrade${NC}"
echo ""

# Start Zsh
exec zsh