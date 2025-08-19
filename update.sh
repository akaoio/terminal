#!/usr/bin/env bash
# AKAOIO TERMINAL - UNIVERSAL UPDATE SCRIPT
# Smart environment detection for all platforms

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

# Mobile-first colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'

# Banner
clear
echo -e "${CYAN}AKAOIO TERMINAL UPDATE${NC}"
echo -e "${BLUE}Environment: $ENV_TYPE${NC}"
echo ""

# Update repository
echo -e "${BLUE}▸ Updating repository...${NC}"
REPO_DIR="$HOME/.akaoio-terminal"

if [ ! -d "$REPO_DIR" ]; then
    git clone https://github.com/akaoio/terminal.git "$REPO_DIR" > /dev/null 2>&1
else
    cd "$REPO_DIR"
    git fetch origin > /dev/null 2>&1
    git reset --hard origin/main > /dev/null 2>&1
fi
echo -e "${GREEN}✓ Repository updated${NC}"

# Update Oh My Zsh
echo -e "${BLUE}▸ Updating Oh My Zsh...${NC}"
if [ -d "$HOME/.oh-my-zsh" ]; then
    cd "$HOME/.oh-my-zsh"
    git pull --rebase --stat origin master > /dev/null 2>&1
    echo -e "${GREEN}✓ Oh My Zsh updated${NC}"
else
    echo -e "${YELLOW}⚠ Oh My Zsh not found${NC}"
fi

# Update Powerlevel10k
echo -e "${BLUE}▸ Updating Powerlevel10k...${NC}"
P10K_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
if [ -d "$P10K_DIR" ]; then
    cd "$P10K_DIR"
    git pull > /dev/null 2>&1
    echo -e "${GREEN}✓ Powerlevel10k updated${NC}"
else
    echo -e "${YELLOW}⚠ Powerlevel10k not found${NC}"
fi

# Update plugins
echo -e "${BLUE}▸ Updating plugins...${NC}"
CUSTOM_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

for plugin in zsh-autosuggestions zsh-syntax-highlighting zsh-completions fzf-tab; do
    if [ -d "$CUSTOM_DIR/plugins/$plugin" ]; then
        cd "$CUSTOM_DIR/plugins/$plugin"
        git pull > /dev/null 2>&1
    fi
done
echo -e "${GREEN}✓ Plugins updated${NC}"

# Update system packages based on environment
echo -e "${BLUE}▸ Updating packages...${NC}"
case "$ENV_TYPE" in
    termux)
        pkg update -y > /dev/null 2>&1
        pkg upgrade -y > /dev/null 2>&1
        ;;
    debian)
        sudo apt-get update -qq > /dev/null 2>&1
        sudo apt-get upgrade -y -qq zsh git curl wget \
            fzf bat ripgrep fd-find neofetch htop ncdu > /dev/null 2>&1
        ;;
    redhat)
        sudo yum update -y zsh git curl wget > /dev/null 2>&1
        ;;
    arch)
        sudo pacman -Syu --noconfirm zsh git curl wget > /dev/null 2>&1
        ;;
    macos)
        if command -v brew &> /dev/null; then
            brew update > /dev/null 2>&1
            brew upgrade zsh git curl wget fzf bat ripgrep fd neofetch htop ncdu > /dev/null 2>&1
        fi
        ;;
esac
echo -e "${GREEN}✓ Packages updated${NC}"

# Update configs from repo
echo -e "${BLUE}▸ Updating configurations...${NC}"
if [ -f "$REPO_DIR/configs/p10k-mobile.zsh" ] && [ "$ENV_TYPE" = "termux" ]; then
    cp "$REPO_DIR/configs/p10k-mobile.zsh" "$HOME/.p10k.zsh"
elif [ -f "$REPO_DIR/configs/p10k-cyberpunk.zsh" ]; then
    cp "$REPO_DIR/configs/p10k-cyberpunk.zsh" "$HOME/.p10k.zsh"
fi
echo -e "${GREEN}✓ Configurations updated${NC}"

# Complete
echo ""
echo -e "${GREEN}═══════════════════════════════════════════${NC}"
echo -e "${CYAN}     UPDATE COMPLETE!${NC}"
echo -e "${GREEN}═══════════════════════════════════════════${NC}"
echo ""
echo -e "${YELLOW}Restart your terminal or run:${NC} ${CYAN}exec zsh${NC}"
echo ""