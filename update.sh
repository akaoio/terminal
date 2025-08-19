#!/usr/bin/env bash

# AKAOIO TERMINAL - UPDATE SCRIPT
# Keep your terminal bleeding edge

set -e

# Colors
NEON_PINK='\033[38;5;198m'
NEON_BLUE='\033[38;5;51m'
NEON_GREEN='\033[38;5;46m'
NEON_PURPLE='\033[38;5;141m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Banner
clear
echo -e "${NEON_PINK}AKAOIO TERMINAL UPDATE${NC}"
echo ""
echo -e "${NEON_GREEN}Updating to the latest terminal config...${NC}"
echo ""

# Update repository
echo -e "${NEON_PURPLE}▸ Pulling latest updates from repository...${NC}"
REPO_DIR="$HOME/.akaoio-terminal"

if [ ! -d "$REPO_DIR" ]; then
    echo -e "${YELLOW}  Repository not found. Cloning...${NC}"
    git clone https://github.com/akaoio/terminal.git "$REPO_DIR" > /dev/null 2>&1
else
    cd "$REPO_DIR"
    git fetch origin > /dev/null 2>&1
    git reset --hard origin/main > /dev/null 2>&1
fi

echo -e "${GREEN}  ✓ Repository updated${NC}"

# Update Oh My Zsh
echo -e "${NEON_PURPLE}▸ Updating Oh My Zsh...${NC}"
if [ -d "$HOME/.oh-my-zsh" ]; then
    cd "$HOME/.oh-my-zsh"
    git pull --rebase --stat origin master > /dev/null 2>&1
    echo -e "${GREEN}  ✓ Oh My Zsh updated${NC}"
else
    echo -e "${YELLOW}  ⚠ Oh My Zsh not found${NC}"
fi

# Update Powerlevel10k
echo -e "${NEON_PURPLE}▸ Updating Powerlevel10k theme...${NC}"
P10K_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
if [ -d "$P10K_DIR" ]; then
    cd "$P10K_DIR"
    git pull > /dev/null 2>&1
    echo -e "${GREEN}  ✓ Powerlevel10k updated${NC}"
else
    echo -e "${YELLOW}  ⚠ Powerlevel10k not found${NC}"
fi

# Update plugins
echo -e "${NEON_PURPLE}▸ Updating Zsh plugins...${NC}"
CUSTOM_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

# Auto-suggestions
if [ -d "$CUSTOM_DIR/plugins/zsh-autosuggestions" ]; then
    cd "$CUSTOM_DIR/plugins/zsh-autosuggestions"
    git pull > /dev/null 2>&1
fi

# Syntax highlighting
if [ -d "$CUSTOM_DIR/plugins/zsh-syntax-highlighting" ]; then
    cd "$CUSTOM_DIR/plugins/zsh-syntax-highlighting"
    git pull > /dev/null 2>&1
fi

# Completions
if [ -d "$CUSTOM_DIR/plugins/zsh-completions" ]; then
    cd "$CUSTOM_DIR/plugins/zsh-completions"
    git pull > /dev/null 2>&1
fi

# FZF tab
if [ -d "$CUSTOM_DIR/plugins/fzf-tab" ]; then
    cd "$CUSTOM_DIR/plugins/fzf-tab"
    git pull > /dev/null 2>&1
fi

echo -e "${GREEN}  ✓ All plugins updated${NC}"

# Update system packages
echo -e "${NEON_PURPLE}▸ Updating system packages...${NC}"
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    if command -v apt-get &> /dev/null; then
        sudo apt-get update -qq > /dev/null 2>&1
        sudo apt-get upgrade -y -qq zsh git curl wget fonts-powerline \
            fzf bat ripgrep fd-find neofetch htop ncdu tldr exa > /dev/null 2>&1
    fi
elif [[ "$OSTYPE" == "darwin"* ]]; then
    if command -v brew &> /dev/null; then
        brew update > /dev/null 2>&1
        brew upgrade zsh git curl wget fzf bat ripgrep fd neofetch htop ncdu tldr exa > /dev/null 2>&1
    fi
fi
echo -e "${GREEN}  ✓ System packages updated${NC}"

# Re-run install script for config updates
echo -e "${NEON_PURPLE}▸ Applying latest configuration...${NC}"
if [ -f "$REPO_DIR/install.sh" ]; then
    bash "$REPO_DIR/install.sh" --update-mode > /dev/null 2>&1
else
    # Fallback to current directory
    if [ -f "./install.sh" ]; then
        bash ./install.sh --update-mode > /dev/null 2>&1
    fi
fi
echo -e "${GREEN}  ✓ Configuration updated${NC}"

# Complete
echo ""
echo -e "${NEON_BLUE}═══════════════════════════════════════════════════════════════════════${NC}"
echo -e "${NEON_GREEN}         ✨ Terminal updated to latest version! ✨${NC}"
echo -e "${NEON_BLUE}═══════════════════════════════════════════════════════════════════════${NC}"
echo ""
echo -e "${NEON_PINK}  Restart your terminal or run: ${NEON_BLUE}exec zsh${NC}"
echo ""