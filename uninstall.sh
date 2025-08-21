#!/usr/bin/env bash
# AKAOIO TERMINAL - UNIVERSAL UNINSTALL SCRIPT
# Smart environment detection for safe removal

set -e

# Environment detection
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

ENV_TYPE=$(detect_environment)

# Dracula Theme Colors
RED='\033[38;5;203m'    # Dracula Red (#ff5555)
GREEN='\033[38;5;84m'   # Dracula Green (#50fa7b)
YELLOW='\033[38;5;228m' # Dracula Yellow (#f1fa8c)
BLUE='\033[38;5;117m'   # Dracula Cyan (#8be9fd)
CYAN='\033[38;5;117m'   # Dracula Cyan (#8be9fd)
PURPLE='\033[38;5;141m' # Dracula Purple (#bd93f9)
PINK='\033[38;5;212m'   # Dracula Pink (#ff79c6)
ORANGE='\033[38;5;215m' # Dracula Orange (#ffb86c)
WHITE='\033[38;5;253m'  # Dracula Foreground (#f8f8f2)
NC='\033[0m'             # No Color

# Banner
clear
echo -e "${RED}AKAOIO TERMINAL UNINSTALL${NC}"
echo -e "${BLUE}Environment: $ENV_TYPE${NC}"
echo ""

echo -e "${YELLOW}⚠ This will remove all terminal configurations!${NC}"
echo -e "${CYAN}Original configs will be restored if backups exist.${NC}"
echo ""

# Confirmation
read -p "$(echo -e ${YELLOW}'Continue? (y/N): '${NC})" -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${GREEN}Uninstall cancelled.${NC}"
    exit 0
fi

echo ""
echo -e "${BLUE}Starting uninstallation...${NC}"
echo ""

# Find latest backup
BACKUP_DIR=$(ls -d $HOME/.terminal-backup-* 2>/dev/null | sort -r | head -n 1)

# Restore shell based on environment
echo -e "${BLUE}▸ Restoring default shell...${NC}"
if [ "$ENV_TYPE" = "termux" ]; then
    # Remove zsh exec from .bashrc
    if [ -f "$HOME/.bashrc" ]; then
        sed -i '/exec zsh/d' "$HOME/.bashrc" 2>/dev/null || true
    fi
    echo -e "${GREEN}✓ Termux shell restored${NC}"
else
    # Other systems: restore bash
    if command -v bash &> /dev/null; then
        if [ "$ENV_TYPE" = "debian" ] || [ "$ENV_TYPE" = "redhat" ]; then
            sudo chsh -s $(which bash) $USER 2>/dev/null || true
        else
            chsh -s $(which bash) 2>/dev/null || true
        fi
    fi
    echo -e "${GREEN}✓ Default shell restored${NC}"
fi

# Remove Oh My Zsh
echo -e "${BLUE}▸ Removing Oh My Zsh...${NC}"
if [ -d "$HOME/.oh-my-zsh" ]; then
    rm -rf "$HOME/.oh-my-zsh"
    echo -e "${GREEN}✓ Oh My Zsh removed${NC}"
else
    echo -e "${YELLOW}⚠ Oh My Zsh not found${NC}"
fi

# Restore configs
echo -e "${BLUE}▸ Restoring original configs...${NC}"
if [ -n "$BACKUP_DIR" ] && [ -d "$BACKUP_DIR" ]; then
    echo -e "${GREEN}Found backup: $BACKUP_DIR${NC}"
    
    # Restore .bashrc
    if [ -f "$BACKUP_DIR/.bashrc" ]; then
        cp "$BACKUP_DIR/.bashrc" "$HOME/.bashrc"
        echo -e "${GREEN}✓ .bashrc restored${NC}"
    fi
    
    # Restore or remove .zshrc
    if [ -f "$BACKUP_DIR/.zshrc" ]; then
        cp "$BACKUP_DIR/.zshrc" "$HOME/.zshrc"
        echo -e "${GREEN}✓ .zshrc restored${NC}"
    else
        rm -f "$HOME/.zshrc"
        echo -e "${GREEN}✓ .zshrc removed${NC}"
    fi
else
    echo -e "${YELLOW}⚠ No backup found${NC}"
    
    # Create minimal .bashrc
    if [ ! -f "$HOME/.bashrc" ]; then
        cat > "$HOME/.bashrc" << 'BASHRC'
# ~/.bashrc

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# Basic settings
export PS1='\u@\h:\w\$ '
export HISTSIZE=1000
export HISTFILESIZE=2000

# Basic aliases
alias ls='ls --color=auto'
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# Safety
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'
BASHRC
        echo -e "${GREEN}✓ Basic .bashrc created${NC}"
    fi
fi

# Remove P10k config
rm -f "$HOME/.p10k.zsh"
echo -e "${GREEN}✓ P10k config removed${NC}"

# Remove tmux config
rm -f "$HOME/.tmux.conf"
echo -e "${GREEN}✓ tmux config removed${NC}"

# Remove dex script
rm -f "$HOME/.local/bin/dex"
echo -e "${GREEN}✓ dex script removed${NC}"

# Remove LazyVim if installed
if [ -d "$HOME/.config/nvim" ]; then
    echo -e "${YELLOW}Remove LazyVim configuration? (y/N): ${NC}"
    read -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        # Check for nvim-backup in backup directory
        if [ -n "$BACKUP_DIR" ] && [ -d "$BACKUP_DIR/nvim-backup" ]; then
            rm -rf "$HOME/.config/nvim"
            mv "$BACKUP_DIR/nvim-backup" "$HOME/.config/nvim"
            echo -e "${GREEN}✓ Original Neovim config restored${NC}"
        else
            rm -rf "$HOME/.config/nvim"
            echo -e "${GREEN}✓ LazyVim removed${NC}"
        fi
    else
        echo -e "${YELLOW}  LazyVim kept${NC}"
    fi
fi

# Remove repository
REPO_DIR="$HOME/.akaoio-terminal"
if [ -d "$REPO_DIR" ]; then
    rm -rf "$REPO_DIR"
    echo -e "${GREEN}✓ Repository removed${NC}"
fi

# Clean up fonts (non-Termux only)
if [ "$ENV_TYPE" != "termux" ]; then
    FONT_DIR="$HOME/.local/share/fonts"
    if [ -d "$FONT_DIR" ]; then
        rm -f "$FONT_DIR"/MesloLGS*.ttf 2>/dev/null || true
        if command -v fc-cache &> /dev/null; then
            fc-cache -f > /dev/null 2>&1
        fi
        echo -e "${GREEN}✓ Fonts cleaned${NC}"
    fi
fi

# Remove Termux-specific file
rm -f "$HOME/install-termux.sh" 2>/dev/null || true

# Complete
echo ""
echo -e "${GREEN}═══════════════════════════════════════════${NC}"
echo -e "${CYAN}     UNINSTALL COMPLETE!${NC}"
echo -e "${GREEN}═══════════════════════════════════════════${NC}"
echo ""
echo -e "${RED}❌ Removed Components:${NC}"
echo -e "  • Oh My Zsh & plugins"
echo -e "  • Powerlevel10k theme"
echo -e "  • tmux configuration"
echo -e "  • dex smart workspace"
echo -e "  • LazyVim (if requested)"
echo ""
echo -e "${YELLOW}Terminal has been restored to defaults.${NC}"
echo -e "${CYAN}Restart your terminal to apply changes.${NC}"
echo ""

# Optionally remove backups
echo -e "${YELLOW}Remove all backup directories? (y/N): ${NC}"
read -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    rm -rf $HOME/.terminal-backup-* 2>/dev/null || true
    echo -e "${GREEN}✓ All backups removed${NC}"
fi

echo ""
echo -e "${CYAN}Thank you for trying AKAOIO Terminal!${NC}"
echo ""