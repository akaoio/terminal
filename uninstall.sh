#!/usr/bin/env bash

# ══════════════════════════════════════════════════════════════════════════════
# AKAOIO TERMINAL - UNINSTALL SCRIPT
# Restore your terminal to defaults
# ══════════════════════════════════════════════════════════════════════════════

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

# Banner
clear
echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${RED}            AKAOIO TERMINAL UNINSTALL            ${NC}"
echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

echo -e "${YELLOW}⚠ WARNING: This will remove all Cyberpunk Terminal configurations!${NC}"
echo -e "${CYAN}Your original configurations will be restored if backups exist.${NC}"
echo ""

# Confirmation
read -p "$(echo -e ${YELLOW}'Are you sure you want to uninstall? (y/N): '${NC})" -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${GREEN}Uninstall cancelled. Your cyberpunk terminal is safe!${NC}"
    exit 0
fi

echo ""
echo -e "${BLUE}Starting uninstallation process...${NC}"
echo ""

# Find latest backup
BACKUP_DIR=$(ls -d $HOME/.terminal-backup-* 2>/dev/null | sort -r | head -n 1)

# Restore original shell
echo -e "${CYAN}▸ Restoring default shell...${NC}"
if command -v bash &> /dev/null; then
    sudo chsh -s $(which bash) $USER 2>/dev/null || chsh -s $(which bash) 2>/dev/null || true
    echo -e "${GREEN}  ✓ Default shell restored to bash${NC}"
fi

# Remove Oh My Zsh
echo -e "${CYAN}▸ Removing Oh My Zsh...${NC}"
if [ -d "$HOME/.oh-my-zsh" ]; then
    rm -rf "$HOME/.oh-my-zsh"
    echo -e "${GREEN}  ✓ Oh My Zsh removed${NC}"
else
    echo -e "${YELLOW}  ⚠ Oh My Zsh not found${NC}"
fi

# Restore original configs
echo -e "${CYAN}▸ Restoring original configurations...${NC}"
if [ -n "$BACKUP_DIR" ] && [ -d "$BACKUP_DIR" ]; then
    echo -e "${GREEN}  Found backup: $BACKUP_DIR${NC}"
    
    # Restore .bashrc
    if [ -f "$BACKUP_DIR/.bashrc" ]; then
        cp "$BACKUP_DIR/.bashrc" "$HOME/.bashrc"
        echo -e "${GREEN}  ✓ .bashrc restored${NC}"
    fi
    
    # Restore .zshrc if it existed before
    if [ -f "$BACKUP_DIR/.zshrc" ]; then
        cp "$BACKUP_DIR/.zshrc" "$HOME/.zshrc"
        echo -e "${GREEN}  ✓ .zshrc restored${NC}"
    else
        # Remove our .zshrc
        rm -f "$HOME/.zshrc"
        echo -e "${GREEN}  ✓ .zshrc removed${NC}"
    fi
    
    # Remove P10k config
    rm -f "$HOME/.p10k.zsh"
    echo -e "${GREEN}  ✓ P10k configuration removed${NC}"
else
    echo -e "${YELLOW}  ⚠ No backup found${NC}"
    
    # Create minimal .bashrc if none exists
    if [ ! -f "$HOME/.bashrc" ]; then
        cat > "$HOME/.bashrc" << 'BASHRC'
# ~/.bashrc: executed by bash(1) for non-login shells.

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# History settings
HISTCONTROL=ignoreboth
shopt -s histappend
HISTSIZE=1000
HISTFILESIZE=2000

# Window size
shopt -s checkwinsize

# Prompt
PS1='\u@\h:\w\$ '

# Enable color support
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    alias grep='grep --color=auto'
fi

# Basic aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# Enable bash completion
if [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
fi
BASHRC
        echo -e "${GREEN}  ✓ Created default .bashrc${NC}"
    fi
    
    # Remove .zshrc
    rm -f "$HOME/.zshrc"
    rm -f "$HOME/.p10k.zsh"
fi

# Remove installed fonts (optional)
echo -e "${CYAN}▸ Cleaning up fonts...${NC}"
FONT_DIR="$HOME/.local/share/fonts"
if [ -d "$FONT_DIR" ]; then
    rm -f "$FONT_DIR"/MesloLGS*.ttf 2>/dev/null || true
    if command -v fc-cache &> /dev/null; then
        fc-cache -f > /dev/null 2>&1
    fi
    echo -e "${GREEN}  ✓ Nerd fonts removed${NC}"
fi

# Remove cache directories
echo -e "${CYAN}▸ Cleaning up cache...${NC}"
rm -rf "$HOME/.cache/p10k-"* 2>/dev/null || true
rm -rf "$HOME/.zsh_history" 2>/dev/null || true
rm -rf "$HOME/.zsh" 2>/dev/null || true
rm -rf "$HOME/.zcompdump"* 2>/dev/null || true
echo -e "${GREEN}  ✓ Cache cleaned${NC}"

# Remove repository
echo -e "${CYAN}▸ Removing repository...${NC}"
rm -rf "$HOME/.akaoio-terminal" 2>/dev/null || true
echo -e "${GREEN}  ✓ Repository removed${NC}"

# Optional: Remove packages (commented out by default)
echo ""
echo -e "${YELLOW}Note: System packages (zsh, git, etc.) were NOT removed.${NC}"
echo -e "${YELLOW}To remove them manually, run:${NC}"
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    if command -v apt-get &> /dev/null; then
        echo -e "${CYAN}  sudo apt-get remove zsh fonts-powerline fzf bat ripgrep fd-find exa${NC}"
    fi
elif [[ "$OSTYPE" == "darwin"* ]]; then
    echo -e "${CYAN}  brew uninstall zsh fzf bat ripgrep fd exa${NC}"
fi

# Complete message
echo ""
echo -e "${GREEN}═══════════════════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}           ✓ Cyberpunk Terminal has been uninstalled!${NC}"
echo -e "${GREEN}═══════════════════════════════════════════════════════════════════════${NC}"
echo ""
echo -e "${CYAN}Your terminal has been restored to its previous state.${NC}"
echo -e "${CYAN}Please restart your terminal or run: ${YELLOW}exec bash${NC}"
echo ""

if [ -n "$BACKUP_DIR" ]; then
    echo -e "${BLUE}Backup location (safe to delete): $BACKUP_DIR${NC}"
fi

echo -e "${MAGENTA}Thank you for trying Akaoio Terminal - Cyberpunk Edition!${NC}"
echo ""

# Switch to bash
exec bash