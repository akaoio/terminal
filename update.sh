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

# Load theme system - single source of truth for colors
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
THEME_NAME="${TERMINAL_THEME:-dracula}"

# Try to load theme from user config first, then from script dir
if [ -f "$HOME/.config/terminal/theme/load.sh" ]; then
    source "$HOME/.config/terminal/theme/load.sh" "$THEME_NAME" 2>/dev/null || {
        # Fallback colors
        GREEN='\033[38;5;84m'
        YELLOW='\033[38;5;228m'
        BLUE='\033[38;5;117m'
        CYAN='\033[38;5;117m'
        RED='\033[38;5;203m'
        PURPLE='\033[38;5;141m'
        PINK='\033[38;5;212m'
        ORANGE='\033[38;5;215m'
        WHITE='\033[38;5;253m'
        NC='\033[0m'
    }
elif [ -f "$SCRIPT_DIR/theme/load.sh" ]; then
    source "$SCRIPT_DIR/theme/load.sh" "$THEME_NAME" 2>/dev/null || {
        # Fallback colors
        GREEN='\033[38;5;84m'
        YELLOW='\033[38;5;228m'
        BLUE='\033[38;5;117m'
        CYAN='\033[38;5;117m'
        RED='\033[38;5;203m'
        PURPLE='\033[38;5;141m'
        PINK='\033[38;5;212m'
        ORANGE='\033[38;5;215m'
        WHITE='\033[38;5;253m'
        NC='\033[0m'
    }
else
    # Fallback colors
    GREEN='\033[38;5;84m'
    YELLOW='\033[38;5;228m'
    BLUE='\033[38;5;117m'
    CYAN='\033[38;5;117m'
    RED='\033[38;5;203m'
    PURPLE='\033[38;5;141m'
    PINK='\033[38;5;212m'
    ORANGE='\033[38;5;215m'
    WHITE='\033[38;5;253m'
    NC='\033[0m'
fi

# Banner
clear
echo -e "${CYAN}AKAOIO TERMINAL UPDATE${NC}"
echo -e "${BLUE}Environment: $ENV_TYPE${NC}"
echo ""

# Update repository
echo -e "${BLUE}▸ Updating repository...${NC}"
# Detect if we're running from the repo or from curl
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
if [ -d "$SCRIPT_DIR/.git" ]; then
    # Running from local repo - DON'T reset, just pull
    REPO_DIR="$SCRIPT_DIR"
    cd "$REPO_DIR"
    git fetch origin > /dev/null 2>&1
    # Only pull if no local changes
    if git diff-index --quiet HEAD --; then
        git pull origin main > /dev/null 2>&1
    else
        echo -e "${YELLOW}  Local changes detected, skipping pull${NC}"
    fi
else
    # Running from curl, use hidden directory
    REPO_DIR="$HOME/.akaoio-terminal"
    if [ ! -d "$REPO_DIR" ]; then
        git clone https://github.com/akaoio/terminal.git "$REPO_DIR" > /dev/null 2>&1
    else
        cd "$REPO_DIR"
        git fetch origin > /dev/null 2>&1
        git reset --hard origin/main > /dev/null 2>&1
    fi
fi
echo -e "${GREEN}✓ Repository updated from GitHub${NC}"

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
        # Update tmux and neovim if installed
        pkg upgrade -y tmux neovim nodejs-lts python 2>/dev/null || true
        ;;
    debian)
        sudo apt-get update -qq > /dev/null 2>&1
        sudo apt-get upgrade -y -qq zsh git curl wget \
            fzf bat ripgrep fd-find neofetch htop ncdu \
            tmux neovim nodejs npm 2>/dev/null || true
        ;;
    redhat)
        sudo yum update -y zsh git curl wget tmux neovim nodejs npm 2>/dev/null || true
        ;;
    arch)
        sudo pacman -Syu --noconfirm zsh git curl wget tmux neovim nodejs npm 2>/dev/null || true
        ;;
    macos)
        if command -v brew &> /dev/null; then
            brew update > /dev/null 2>&1
            brew upgrade zsh git curl wget fzf bat ripgrep fd neofetch htop ncdu \
                tmux neovim node 2>/dev/null || true
        fi
        ;;
esac
echo -e "${GREEN}✓ Packages updated${NC}"

# Force update ALL configs from repo (overwrite local changes)
echo -e "${BLUE}▸ Syncing all configurations from GitHub...${NC}"

# Update p10k config
if [ -f "$REPO_DIR/configs/p10k.zsh" ]; then
    cp -f "$REPO_DIR/configs/p10k.zsh" "$HOME/.p10k.zsh"
    echo -e "${GREEN}  ✓ Powerlevel10k config synced${NC}"
else
    echo -e "${RED}  ✗ p10k.zsh not found in repo${NC}"
fi

# Update theme system
echo -e "${BLUE}▸ Updating theme system...${NC}"
if [ -d "$REPO_DIR/theme" ]; then
    mkdir -p "$HOME/.config/terminal"
    cp -rf "$REPO_DIR/theme" "$HOME/.config/terminal/" 2>/dev/null
    echo -e "${GREEN}  ✓ Theme system updated${NC}"
    
    # Show current theme
    if [ -f "$HOME/.config/terminal/theme/cli.js" ] && command -v node &> /dev/null; then
        CURRENT_THEME=$(node "$HOME/.config/terminal/theme/cli.js" get 2>/dev/null | grep -o '"name":[[:space:]]*"[^"]*"' | cut -d'"' -f4 || echo "dracula")
        echo -e "${CYAN}  Current theme: $CURRENT_THEME${NC}"
    fi
fi

# Sync any other config files from repo
if [ -d "$REPO_DIR/configs" ]; then
    # FORCE copy tmux config (without dot prefix in repo)
    if [ -f "$REPO_DIR/configs/tmux.conf" ]; then
        cp -f "$REPO_DIR/configs/tmux.conf" "$HOME/.tmux.conf"
        echo -e "${GREEN}  ✓ tmux config force synced from repo${NC}"
    fi
    
    # Copy nvim configs if exists
    if [ -d "$REPO_DIR/configs/nvim" ]; then
        mkdir -p "$HOME/.config/nvim"
        cp -rf "$REPO_DIR/configs/nvim/"* "$HOME/.config/nvim/" 2>/dev/null && echo -e "${GREEN}  ✓ Neovim configs synced${NC}"
    fi
    
    # Copy any zsh custom configs
    [ -f "$REPO_DIR/configs/.zshrc.custom" ] && cp -f "$REPO_DIR/configs/.zshrc.custom" "$HOME/.zshrc.custom" && echo -e "${GREEN}  ✓ Custom zsh config synced${NC}"
fi

# Force update dex script from repo
if [ -f "$REPO_DIR/dex" ]; then
    mkdir -p "$HOME/.local/bin"
    # Remove existing file or symlink to avoid conflicts
    [ -e "$HOME/.local/bin/dex" ] && rm -f "$HOME/.local/bin/dex"
    cp -f "$REPO_DIR/dex" "$HOME/.local/bin/dex"
    chmod +x "$HOME/.local/bin/dex"
    echo -e "${GREEN}  ✓ dex script updated from GitHub${NC}"
else
    echo -e "${YELLOW}  ⚠ dex script not found in repo${NC}"
fi

# Note: tmux config already synced from repo above

# Check and update Neovim to latest version
echo -e "${BLUE}▸ Checking Neovim version...${NC}"
if command -v nvim &> /dev/null; then
    NVIM_VERSION=$(nvim --version 2>/dev/null | head -1 | grep -o '[0-9]\+\.[0-9]\+' || echo "0.0")
    NVIM_MAJOR=$(echo $NVIM_VERSION | cut -d. -f1)
    NVIM_MINOR=$(echo $NVIM_VERSION | cut -d. -f2)
    
    if [ "$NVIM_MAJOR" -eq 0 ] && [ "$NVIM_MINOR" -lt 8 ]; then
        echo -e "${YELLOW}  Neovim v$NVIM_VERSION is too old, updating...${NC}"
        
        # Install latest Neovim based on platform
        case "$ENV_TYPE" in
            debian)
                # Download latest binary
                if [ "$(uname -m)" = "x86_64" ]; then
                    wget -q https://github.com/neovim/neovim/releases/download/v0.10.2/nvim-linux64.tar.gz -O /tmp/nvim.tar.gz
                    sudo tar -xzf /tmp/nvim.tar.gz -C /opt/
                    sudo ln -sf /opt/nvim-linux64/bin/nvim /usr/local/bin/nvim
                    rm /tmp/nvim.tar.gz
                    echo -e "${GREEN}  ✓ Neovim updated to v0.10.2${NC}"
                fi
                ;;
            termux)
                pkg upgrade -y neovim
                ;;
            macos)
                brew upgrade neovim
                ;;
        esac
    else
        echo -e "${GREEN}  ✓ Neovim v$NVIM_VERSION is sufficient${NC}"
    fi
else
    echo -e "${YELLOW}  Neovim not found, please run install.sh${NC}"
fi

# Install or Update LazyVim
echo -e "${BLUE}▸ Setting up LazyVim...${NC}"
if command -v nvim &> /dev/null; then
    if [ ! -d "$HOME/.config/nvim" ]; then
        # Fresh install LazyVim
        echo -e "${YELLOW}  Installing LazyVim...${NC}"
        git clone https://github.com/LazyVim/starter "$HOME/.config/nvim" > /dev/null 2>&1
        rm -rf "$HOME/.config/nvim/.git"
        echo -e "${GREEN}  ✓ LazyVim installed${NC}"
    else
        echo -e "${YELLOW}  LazyVim already configured${NC}"
    fi
    # Ensure lazy.nvim is installed
    LAZY_PATH="$HOME/.local/share/nvim/lazy/lazy.nvim"
    if [ ! -d "$LAZY_PATH" ]; then
        git clone --filter=blob:none --branch=stable https://github.com/folke/lazy.nvim.git "$LAZY_PATH" > /dev/null 2>&1
    fi
else
    echo -e "${YELLOW}  Neovim not installed${NC}"
fi

# Update Claude Code
echo -e "${BLUE}▸ Updating Claude Code...${NC}"
if command -v claude &> /dev/null; then
    # Check if installed via npm/bun
    if command -v bun &> /dev/null && bun list -g 2>/dev/null | grep -q "@anthropic/claude-code"; then
        bun update -g @anthropic/claude-code > /dev/null 2>&1
        echo -e "${GREEN}✓ Claude Code updated via bun${NC}"
    elif command -v npm &> /dev/null && npm list -g @anthropic/claude-code 2>/dev/null | grep -q "@anthropic/claude-code"; then
        npm update -g @anthropic/claude-code > /dev/null 2>&1
        echo -e "${GREEN}✓ Claude Code updated via npm${NC}"
    else
        # Binary installation - download latest
        ARCH=$(uname -m)
        OS=$(uname -s | tr '[:upper:]' '[:lower:]')
        
        case "$ARCH" in
            x86_64|amd64) ARCH="x64" ;;
            aarch64|arm64) ARCH="arm64" ;;
            armv7l|armv7) ARCH="armv7" ;;
        esac
        
        if [ "$OS" = "darwin" ]; then
            CLAUDE_URL="https://github.com/anthropics/claude-code/releases/latest/download/claude-macos-${ARCH}"
        else
            CLAUDE_URL="https://github.com/anthropics/claude-code/releases/latest/download/claude-linux-${ARCH}"
        fi
        
        if curl -fsSL "$CLAUDE_URL" -o /tmp/claude 2>/dev/null; then
            chmod +x /tmp/claude
            if [ -f "/usr/local/bin/claude" ]; then
                sudo mv /tmp/claude /usr/local/bin/claude 2>/dev/null || mv /tmp/claude "$HOME/.local/bin/claude"
            else
                mv /tmp/claude "$HOME/.local/bin/claude"
            fi
            echo -e "${GREEN}✓ Claude Code binary updated${NC}"
        else
            echo -e "${YELLOW}  Claude Code update failed${NC}"
        fi
    fi
else
    echo -e "${YELLOW}  Claude Code not installed${NC}"
fi

# Fix Claude CLI aliases if missing or incorrect
echo -e "${BLUE}▸ Checking Claude CLI aliases...${NC}"
if ! grep -q "alias cc='claude --dangerously-skip-permissions'" "$HOME/.zshrc" 2>/dev/null; then
    echo -e "${YELLOW}  Updating Claude CLI aliases...${NC}"
    # Remove old aliases if they exist
    sed -i '/^alias cc=/d' "$HOME/.zshrc" 2>/dev/null
    sed -i '/^alias dex=/d' "$HOME/.zshrc" 2>/dev/null
    sed -i '/^unalias cc/d' "$HOME/.zshrc" 2>/dev/null
    sed -i '/^unalias dex/d' "$HOME/.zshrc" 2>/dev/null
    sed -i '/# Claude CLI aliases/d' "$HOME/.zshrc" 2>/dev/null
    
    # Find the line with "# System shortcuts" and add after it
    if grep -q "# System shortcuts" "$HOME/.zshrc"; then
        # Add Claude aliases after System shortcuts section
        sed -i '/^alias week=/a\\n# Claude CLI aliases (override system cc compiler)\nunalias cc 2>/dev/null\nunalias dex 2>/dev/null\nalias cc='"'"'claude --dangerously-skip-permissions'"'"'\nalias dex='"'"'claude --dangerously-skip-permissions'"'"'' "$HOME/.zshrc" 2>/dev/null || \
        # macOS compatibility
        sed -i '' '/^alias week=/a\\
# Claude CLI aliases (override system cc compiler)\\
unalias cc 2>/dev/null\\
unalias dex 2>/dev/null\\
alias cc='"'"'claude --dangerously-skip-permissions'"'"'\\
alias dex='"'"'claude --dangerously-skip-permissions'"'"'
' "$HOME/.zshrc" 2>/dev/null || \
        # Fallback: append to end of file
        echo -e "\n# Claude CLI alias\nalias cc='claude --dangerously-skip-permissions'" >> "$HOME/.zshrc"
    else
        # Append to end of file if pattern not found
        echo -e "\n# Claude CLI alias\nalias cc='claude --dangerously-skip-permissions'" >> "$HOME/.zshrc"
    fi
    echo -e "${GREEN}✓ Claude CLI aliases updated${NC}"
else
    echo -e "${GREEN}✓ Claude CLI aliases already configured${NC}"
fi

echo -e "${GREEN}✓ Configurations updated${NC}"

# Complete
echo ""
echo -e "${GREEN}═══════════════════════════════════════════${NC}"
echo -e "${CYAN}     UPDATE COMPLETE!${NC}"
echo -e "${GREEN}═══════════════════════════════════════════${NC}"
echo ""
echo -e "${GREEN}✅ Updated Components:${NC}"
echo -e "  • Oh My Zsh & plugins"
echo -e "  • Powerlevel10k theme"
echo -e "  • System packages"
echo -e "  • tmux & dex script"
echo -e "  • LazyVim (if installed)"
echo -e "  • Claude Code AI assistant"
echo ""
echo -e "${YELLOW}Restart your terminal or run:${NC} ${CYAN}exec zsh${NC}"
echo -e "${BLUE}Smart workspace:${NC} ${CYAN}dex${NC}"
echo ""