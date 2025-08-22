#!/usr/bin/env bash
# AKAOIO TERMINAL - UNIVERSAL MOBILE-FIRST INSTALLER
# Smart detection for Termux, Linux, macOS
# Compact, beautiful, no backgrounds

set -e  # Exit on error

# Save original directory
ORIGINAL_DIR="$(pwd)"

# SMART ENVIRONMENT DETECTION
detect_environment() {
    # Check for Termux first
    if [ -n "$TERMUX_VERSION" ] || [ -d "/data/data/com.termux" ]; then
        echo "termux"
    # Check for containerized environments
    elif [ -f /run/.containerenv ] || [ -f /.dockerenv ]; then
        echo "container"
    # Check for WSL
    elif grep -qi microsoft /proc/version 2>/dev/null; then
        echo "wsl"
    # Check for macOS
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        echo "macos"
    # Linux detection with immutable check
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        # Check for immutable systems first (Bazzite, Silverblue, etc.)
        if [ -f /usr/bin/rpm-ostree ]; then
            if [ -f /etc/os-release ]; then
                . /etc/os-release
                if [[ "$ID" == "bazzite" ]]; then
                    echo "bazzite"
                else
                    echo "immutable"
                fi
            else
                echo "immutable"
            fi
        # Regular Linux distros
        elif command -v apt-get &> /dev/null; then
            echo "debian"
        elif command -v dnf &> /dev/null; then
            echo "redhat"
        elif command -v yum &> /dev/null; then
            echo "redhat"
        elif command -v pacman &> /dev/null; then
            echo "arch"
        elif command -v zypper &> /dev/null; then
            echo "suse"
        elif command -v apk &> /dev/null; then
            echo "alpine"
        else
            echo "linux"
        fi
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

# Load theme system - single source of truth for colors
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
THEME_NAME="${TERMINAL_THEME:-dracula}"

# Load theme colors
if [ -f "$SCRIPT_DIR/theme/load.sh" ]; then
    source "$SCRIPT_DIR/theme/load.sh" "$THEME_NAME" 2>/dev/null || {
        # Fallback to hardcoded Dracula colors if theme system fails
        PURPLE='\033[38;2;189;147;249m'
        GREEN='\033[38;2;80;250;123m'
        CYAN='\033[38;2;139;233;253m'
        PINK='\033[38;2;255;121;198m'
        YELLOW='\033[38;2;241;250;140m'
        RED='\033[38;2;255;85;85m'
        ORANGE='\033[38;2;255;184;108m'
        BLUE='\033[38;2;139;233;253m'
        COMMENT='\033[38;2;98;114;164m'
        NC='\033[0m'
    }
else
    # Fallback colors
    PURPLE='\033[38;2;189;147;249m'
    GREEN='\033[38;2;80;250;123m'
    CYAN='\033[38;2;139;233;253m'
    PINK='\033[38;2;255;121;198m'
    YELLOW='\033[38;2;241;250;140m'
    RED='\033[38;2;255;85;85m'
    ORANGE='\033[38;2;255;184;108m'
    BLUE='\033[38;2;139;233;253m'
    COMMENT='\033[38;2;98;114;164m'
    NC='\033[0m'
fi

# Backup directory
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
        printf "${CYAN}[*] $text...${NC}"
        return 0
    fi
    
    # For compatible terminals, use dots animation instead of spinners
    printf "${CYAN}[*] $text${NC}"
    
    (
        trap 'exit 0' TERM INT
        local dots=""
        local max_dots=3
        local count=0
        
        while true; do
            printf "\r${CYAN}[*] $text$dots${NC}   "
            
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

# Install Homebrew if needed
install_homebrew() {
    if ! command -v brew &> /dev/null; then
        echo -e "${YELLOW}  Installing Homebrew...${NC}"
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        
        # Add to PATH based on system
        if [ -d "/home/linuxbrew/.linuxbrew" ]; then
            eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
        elif [ -d "/opt/homebrew" ]; then
            eval "$(/opt/homebrew/bin/brew shellenv)"
        fi
    fi
}

# Smart package installation
install_packages() {
    echo -e "${BLUE}▸ Installing packages for $ENV_TYPE${NC}"
    
    case "$ENV_TYPE" in
        termux)
            show_loading "Updating Termux packages"
            pkg update -y > /dev/null 2>&1
            pkg install -y zsh git curl wget jq nano \
                fzf bat ripgrep fd neofetch htop ncdu \
                cmatrix python nodejs > /dev/null 2>&1
            stop_loading
            ;;
            
        bazzite|immutable)
            echo -e "${YELLOW}  Immutable system detected - using Homebrew${NC}"
            install_homebrew
            show_loading "Installing packages via Homebrew"
            brew install zsh git curl wget jq fzf bat ripgrep fd neofetch htop ncdu eza > /dev/null 2>&1
            stop_loading
            
            # Try to layer zsh if possible
            echo -e "${YELLOW}  Attempting to layer zsh (may require reboot)${NC}"
            sudo rpm-ostree install zsh util-linux-user --idempotent 2>/dev/null || true
            ;;
            
        container)
            echo -e "${YELLOW}  Container environment - attempting package installation${NC}"
            if command -v apt-get &> /dev/null; then
                apt-get update && apt-get install -y zsh git curl wget jq
            elif command -v dnf &> /dev/null; then
                dnf install -y zsh git curl wget jq
            elif command -v apk &> /dev/null; then
                apk add --no-cache zsh git curl wget jq
            fi
            ;;
            
        wsl|debian)
            show_loading "Installing packages via APT"
            sudo apt-get update -qq > /dev/null 2>&1
            sudo apt-get install -y -qq zsh git curl wget jq \
                fzf ripgrep fd-find neofetch htop ncdu cmatrix > /dev/null 2>&1
            # Try to install bat (might not be available on older versions)
            sudo apt-get install -y -qq bat 2>/dev/null || true
            stop_loading
            ;;
            
        redhat)
            show_loading "Installing packages via DNF/YUM"
            if command -v dnf &> /dev/null; then
                sudo dnf install -y zsh git curl wget jq nano \
                    fzf ripgrep fd-find neofetch htop ncdu cmatrix \
                    util-linux-user > /dev/null 2>&1
                # Try to install bat
                sudo dnf install -y bat 2>/dev/null || true
            else
                sudo yum install -y zsh git curl wget jq nano cmatrix > /dev/null 2>&1
            fi
            stop_loading
            ;;
            
        arch)
            show_loading "Installing packages via Pacman"
            sudo pacman -Syu --noconfirm > /dev/null 2>&1
            sudo pacman -S --noconfirm zsh git curl wget jq nano \
                fzf bat ripgrep fd neofetch htop ncdu cmatrix > /dev/null 2>&1
            stop_loading
            ;;
            
        suse)
            show_loading "Installing packages via Zypper"
            sudo zypper install -y zsh git curl wget jq nano \
                fzf ripgrep fd neofetch htop ncdu cmatrix > /dev/null 2>&1
            # Try to install bat
            sudo zypper install -y bat 2>/dev/null || true
            stop_loading
            ;;
            
        alpine)
            show_loading "Installing packages via APK"
            sudo apk add --no-cache zsh git curl wget jq nano \
                fzf bat ripgrep fd neofetch htop ncdu cmatrix > /dev/null 2>&1
            stop_loading
            ;;
            
        macos)
            echo -e "${YELLOW}  Using Homebrew for macOS${NC}"
            install_homebrew
            show_loading "Installing packages"
            brew install zsh git curl wget jq fzf bat ripgrep fd neofetch htop ncdu eza cmatrix > /dev/null 2>&1
            stop_loading
            ;;
            
        *)
            echo -e "${YELLOW}⚠ Unknown environment, attempting Homebrew installation${NC}"
            install_homebrew
            brew install zsh git curl wget jq fzf bat ripgrep fd neofetch htop ncdu eza cmatrix > /dev/null 2>&1
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
        # Install Nerd Font for Termux
        show_loading "Installing Nerd Fonts for Termux"
        
        # Create font directory for Termux
        TERMUX_FONT_DIR="$HOME/.termux"
        mkdir -p "$TERMUX_FONT_DIR"
        
        # Download DejaVu Sans Mono Nerd Font (works well with Termux)
        if ! [ -f "$TERMUX_FONT_DIR/font.ttf" ]; then
            # Try DejaVu Sans Mono Nerd Font first (smaller, better compatibility)
            if wget -q -O "$TERMUX_FONT_DIR/font.ttf" \
                "https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/DejaVuSansMono/Regular/DejaVuSansMNerdFont-Regular.ttf" 2>/dev/null; then
                echo -e "${GREEN}  ✓ DejaVu Sans Mono Nerd Font installed${NC}"
            else
                # Fallback to MesloLGS NF
                wget -q -O "$TERMUX_FONT_DIR/font.ttf" \
                    "https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Regular.ttf" 2>/dev/null || true
                echo -e "${GREEN}  ✓ MesloLGS Nerd Font installed${NC}"
            fi
            
            # Apply font immediately
            termux-reload-settings 2>/dev/null || true
        fi
        
        stop_loading
        
        # Configure Termux properties for better icon support
        TERMUX_PROPS="$HOME/.termux/termux.properties"
        if ! [ -f "$TERMUX_PROPS" ]; then
            cat > "$TERMUX_PROPS" << 'PROPS'
# Enable true color support
use-black-ui = true
# Extra keys for better navigation
extra-keys = [['ESC','/','-','HOME','UP','END','PGUP'],['TAB','CTRL','ALT','LEFT','DOWN','RIGHT','PGDN']]
PROPS
            termux-reload-settings 2>/dev/null || true
        fi
        
        echo -e "${CYAN}  Font installed! Restart Termux app to apply.${NC}"
        echo -e "${YELLOW}  Alternative: Install Termux:Styling from F-Droid for more fonts${NC}"
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

# Install tmux with smart configuration
install_tmux() {
    echo -e "${BLUE}▸ Installing tmux${NC}"
    
    # Install tmux based on platform
    case "$ENV_TYPE" in
        termux)
            show_loading "Installing tmux"
            pkg install -y tmux > /dev/null 2>&1
            stop_loading
            ;;
        debian|wsl)
            show_loading "Installing tmux"
            sudo apt-get install -y -qq tmux > /dev/null 2>&1
            stop_loading
            ;;
        redhat)
            show_loading "Installing tmux"
            if command -v dnf &> /dev/null; then
                sudo dnf install -y tmux > /dev/null 2>&1
            else
                sudo yum install -y tmux > /dev/null 2>&1
            fi
            stop_loading
            ;;
        arch)
            show_loading "Installing tmux"
            sudo pacman -S --noconfirm tmux > /dev/null 2>&1
            stop_loading
            ;;
        macos)
            show_loading "Installing tmux"
            brew install tmux > /dev/null 2>&1
            stop_loading
            ;;
        *)
            echo -e "${YELLOW}  Attempting tmux installation via package manager${NC}"
            if command -v apt-get &> /dev/null; then
                sudo apt-get install -y tmux > /dev/null 2>&1
            elif command -v brew &> /dev/null; then
                brew install tmux > /dev/null 2>&1
            fi
            ;;
    esac
    
    # Copy tmux config from repo or create default
    show_loading "Configuring tmux"
    if [ -f "$SCRIPT_DIR/configs/tmux.conf" ]; then
        cp "$SCRIPT_DIR/configs/tmux.conf" "$HOME/.tmux.conf"
    else
        cat > "$HOME/.tmux.conf" << 'TMUX'
# AKAOIO TMUX CONFIGURATION

# Enable 256 colors
set -g default-terminal "screen-256color"
set -ga terminal-overrides ",*256col*:Tc"

# Enable mouse support
set -g mouse on

# Set prefix to Ctrl-a (easier to reach than Ctrl-b)
unbind C-b
set-option -g prefix C-a
bind-key C-a send-prefix

# Split panes using mobile-friendly keys
bind h split-window -h  # Horizontal split (side by side)
bind v split-window -v  # Vertical split (top/bottom)
unbind '"'
unbind %

# Mobile-friendly pane navigation (easier than arrow keys)
bind j select-pane -D  # Down
bind k select-pane -U  # Up
bind l select-pane -R  # Right
bind b select-pane -L  # Left (b for back)

# Quick pane resizing (mobile-friendly)
bind + resize-pane -U 5
bind = resize-pane -D 5
bind 9 resize-pane -L 5
bind 0 resize-pane -R 5

# Reload config with r
bind r source-file ~/.tmux.conf \; display-message "Config reloaded!"

# Switch panes using Alt-arrow without prefix
bind -n M-Left select-pane -L
bind -n M-Right select-pane -R
bind -n M-Up select-pane -U
bind -n M-Down select-pane -D

# Don't rename windows automatically
set-option -g allow-rename off

# Start windows and panes at 1, not 0
set -g base-index 1
setw -g pane-base-index 1

# Renumber windows on close
set -g renumber-windows on

# Increase history limit
set -g history-limit 10000

# No delay for escape key press
set -sg escape-time 0

# Status bar customization - Cyberpunk theme
set -g status-bg colour235
set -g status-fg colour198
set -g status-interval 60
set -g status-left-length 30
set -g status-left '#[fg=colour51,bold][#S] '
set -g status-right '#[fg=colour226]#(whoami)@#H #[fg=colour51]%H:%M'

# Window status
setw -g window-status-format '#[fg=colour245]#I:#W'
setw -g window-status-current-format '#[fg=colour198,bold]#I:#W'

# Pane borders
set -g pane-border-style fg=colour238
set -g pane-active-border-style fg=colour51

# Messages
set -g message-style bg=colour235,fg=colour198

# Activity monitoring
setw -g monitor-activity on
set -g visual-activity off

# Preserve working directory when splitting
bind '"' split-window -c "#{pane_current_path}"
bind % split-window -h -c "#{pane_current_path}"
bind c new-window -c "#{pane_current_path}"
TMUX
    fi
    stop_loading
    
    echo -e "${GREEN}✓ tmux installed and configured${NC}"
    sleep 1
}

# Install Claude Code - Anthropic's AI coding assistant
install_claude_code() {
    echo -e "${BLUE}▸ Installing Claude Code${NC}"
    
    # Check if already installed
    if command -v claude &> /dev/null; then
        echo -e "${GREEN}✓ Claude Code already installed${NC}"
        claude --version 2>/dev/null || true
        return 0
    fi
    
    # Method 1: Try official binary installer (fastest and recommended)
    show_loading "Installing Claude Code via official installer"
    if curl -fsSL https://claude.ai/install.sh | bash > /dev/null 2>&1; then
        stop_loading
        echo -e "${GREEN}✓ Claude Code binary installed${NC}"
        
        # Verify installation
        if command -v claude &> /dev/null; then
            # Run claude doctor to verify everything is working
            claude doctor > /dev/null 2>&1 || true
            echo -e "${CYAN}  Run 'claude doctor' to verify installation${NC}"
            return 0
        fi
    else
        stop_loading
        echo -e "${YELLOW}  Official installer failed, trying npm/bun${NC}"
    fi
    
    # Method 2: Fall back to npm/bun installation
    # Try bun first (faster)
    if command -v bun &> /dev/null; then
        show_loading "Installing Claude Code via bun"
        bun install -g @anthropic/claude > /dev/null 2>&1
        stop_loading
        if command -v claude &> /dev/null; then
            echo -e "${GREEN}✓ Claude Code installed via bun${NC}"
            return 0
        fi
    fi
    
    # Try npm
    if command -v npm &> /dev/null; then
        show_loading "Installing Claude Code via npm"
        npm install -g @anthropic/claude > /dev/null 2>&1
        stop_loading
        if command -v claude &> /dev/null; then
            echo -e "${GREEN}✓ Claude Code installed via npm${NC}"
            return 0
        fi
    fi
    
    # Install Node.js first if needed, then try npm
    if ! command -v npm &> /dev/null; then
        echo -e "${YELLOW}  Installing Node.js first${NC}"
        case "$ENV_TYPE" in
            termux)
                pkg install -y nodejs-lts > /dev/null 2>&1
                ;;
            debian|wsl)
                sudo apt-get install -y -qq nodejs npm > /dev/null 2>&1
                ;;
            redhat)
                if command -v dnf &> /dev/null; then
                    sudo dnf install -y nodejs npm > /dev/null 2>&1
                else
                    sudo yum install -y nodejs npm > /dev/null 2>&1
                fi
                ;;
            arch)
                sudo pacman -S --noconfirm nodejs npm > /dev/null 2>&1
                ;;
            macos)
                brew install node > /dev/null 2>&1
                ;;
        esac
        
        if command -v npm &> /dev/null; then
            show_loading "Installing Claude Code via npm"
            npm install -g @anthropic/claude > /dev/null 2>&1
            stop_loading
            if command -v claude &> /dev/null; then
                echo -e "${GREEN}✓ Claude Code installed via npm${NC}"
                return 0
            fi
        fi
    fi
    
    # Final check and user message
    if command -v claude &> /dev/null; then
        echo -e "${GREEN}✓ Claude Code ready to use!${NC}"
        echo -e "${CYAN}  Run 'claude doctor' to verify installation${NC}"
        echo -e "${CYAN}  Run 'claude --help' for usage${NC}"
    else
        echo -e "${YELLOW}⚠ Claude Code installation incomplete${NC}"
        echo -e "${CYAN}  You can install manually: curl -fsSL https://claude.ai/install.sh | bash${NC}"
    fi
    
    sleep 1
}

# Install LazyVim - modern Neovim configuration
install_lazyvim() {
    echo -e "${BLUE}▸ Installing LazyVim (Neovim)${NC}"
    
    # Check if Neovim is already installed and version is sufficient
    if command -v nvim &> /dev/null; then
        NVIM_VERSION=$(nvim --version 2>/dev/null | head -1 | grep -o '[0-9]\+\.[0-9]\+' | head -1 || echo "0.0")
        NVIM_MAJOR=$(echo "$NVIM_VERSION" | cut -d. -f1)
        NVIM_MINOR=$(echo "$NVIM_VERSION" | cut -d. -f2)
        
        if [ "$NVIM_MAJOR" -gt 0 ] || [ "$NVIM_MINOR" -ge 8 ]; then
            echo -e "${GREEN}  ✓ Neovim v$NVIM_VERSION already installed${NC}"
            NEED_INSTALL=false
        else
            echo -e "${YELLOW}  ⚠ Neovim v$NVIM_VERSION is too old, need >= 0.8.0${NC}"
            NEED_INSTALL=true
        fi
    else
        NEED_INSTALL=true
    fi
    
    # Install Neovim if needed
    if [ "$NEED_INSTALL" = "true" ]; then
        case "$ENV_TYPE" in
        termux)
            show_loading "Installing Neovim"
            pkg install -y neovim nodejs-lts python > /dev/null 2>&1
            stop_loading
            ;;
        debian|wsl)
            show_loading "Installing Neovim"
            # Force install latest Neovim (LazyVim requires >= 0.8.0)
            
            # Method 1: Download pre-built binary (fastest, always latest)
            ARCH=$(uname -m)
            if [ "$ARCH" = "x86_64" ]; then
                if wget -q https://github.com/neovim/neovim/releases/download/v0.10.2/nvim-linux64.tar.gz -O /tmp/nvim.tar.gz > /dev/null 2>&1; then
                    sudo tar -xzf /tmp/nvim.tar.gz -C /opt/ > /dev/null 2>&1
                    sudo ln -sf /opt/nvim-linux64/bin/nvim /usr/local/bin/nvim
                    rm /tmp/nvim.tar.gz
                    sudo apt-get install -y -qq python3-neovim nodejs npm > /dev/null 2>&1 || true
                    stop_loading
                    echo -e "${GREEN}  ✓ Neovim v0.10.2 installed${NC}"
                else
                    # Fallback to other methods if download fails
                    stop_loading
                    echo -e "${YELLOW}  Binary download failed, trying alternatives...${NC}"
                fi
            fi
            
            # Method 2: Try AppImage if binary failed
            if ! command -v nvim &> /dev/null || [ "$(nvim --version 2>/dev/null | head -1 | grep -o '[0-9]\+\.[0-9]\+' | cut -d. -f2)" -lt 8 ] 2>/dev/null; then
                show_loading "Trying AppImage method"
                if wget -q https://github.com/neovim/neovim/releases/latest/download/nvim.appimage -O /tmp/nvim.appimage > /dev/null 2>&1; then
                    chmod +x /tmp/nvim.appimage
                    cd /tmp && ./nvim.appimage --appimage-extract > /dev/null 2>&1
                    sudo mv squashfs-root /opt/nvim 2>/dev/null || mv squashfs-root $HOME/.local/nvim
                    sudo ln -sf /opt/nvim/AppRun /usr/local/bin/nvim 2>/dev/null || ln -sf $HOME/.local/nvim/AppRun $HOME/.local/bin/nvim
                    cd - > /dev/null
                    rm -f /tmp/nvim.appimage
                    stop_loading
                    echo -e "${GREEN}  ✓ Neovim AppImage installed${NC}"
                else
                    # Last resort: use system package
                    sudo apt-get install -y -qq neovim > /dev/null 2>&1 || true
                    stop_loading
                    echo -e "${YELLOW}  ⚠ Using system Neovim (may be old)${NC}"
                fi
            fi
            
            # Install dependencies
            sudo apt-get install -y -qq python3-neovim nodejs npm > /dev/null 2>&1 || true
            ;;
        redhat)
            show_loading "Installing Neovim"
            # Try to install latest binary first
            ARCH=$(uname -m)
            if [ "$ARCH" = "x86_64" ]; then
                if wget -q https://github.com/neovim/neovim/releases/download/v0.10.2/nvim-linux64.tar.gz -O /tmp/nvim.tar.gz > /dev/null 2>&1; then
                    sudo tar -xzf /tmp/nvim.tar.gz -C /opt/
                    sudo ln -sf /opt/nvim-linux64/bin/nvim /usr/local/bin/nvim
                    rm /tmp/nvim.tar.gz
                    stop_loading
                    echo -e "${GREEN}  ✓ Neovim v0.10.2 installed${NC}"
                else
                    # Fallback to package manager
                    if command -v dnf &> /dev/null; then
                        sudo dnf install -y epel-release > /dev/null 2>&1
                        sudo dnf install -y neovim python3-neovim nodejs npm > /dev/null 2>&1
                    else
                        sudo yum install -y epel-release > /dev/null 2>&1
                        sudo yum install -y neovim python3-neovim nodejs npm > /dev/null 2>&1
                    fi
                    stop_loading
                fi
            else
                # Non-x86_64 arch, use package manager
                if command -v dnf &> /dev/null; then
                    sudo dnf install -y neovim python3-neovim nodejs npm > /dev/null 2>&1
                else
                    sudo yum install -y epel-release > /dev/null 2>&1
                    sudo yum install -y neovim python3-neovim nodejs npm > /dev/null 2>&1
                fi
                stop_loading
            fi
            ;;
        arch)
            show_loading "Installing Neovim"
            sudo pacman -S --noconfirm neovim python-pynvim nodejs npm > /dev/null 2>&1
            stop_loading
            ;;
        macos)
            show_loading "Installing Neovim"
            brew install neovim node python > /dev/null 2>&1
            stop_loading
            ;;
        *)
            echo -e "${YELLOW}  Attempting Neovim installation${NC}"
            if command -v apt-get &> /dev/null; then
                sudo apt-get install -y neovim nodejs npm > /dev/null 2>&1
            elif command -v brew &> /dev/null; then
                brew install neovim node > /dev/null 2>&1
            fi
            ;;
        esac
    fi
    
    # Backup existing Neovim config if exists
    if [ -d "$HOME/.config/nvim" ]; then
        echo -e "${YELLOW}  Backing up existing Neovim config${NC}"
        mv "$HOME/.config/nvim" "$BACKUP_DIR/nvim-backup" 2>/dev/null || true
    fi
    
    # Check Neovim version before installing LazyVim
    if command -v nvim &> /dev/null; then
        NVIM_VERSION=$(nvim --version | head -1 | grep -o 'v[0-9]\+\.[0-9]\+' | cut -c2-)
        NVIM_MAJOR=$(echo $NVIM_VERSION | cut -d. -f1)
        NVIM_MINOR=$(echo $NVIM_VERSION | cut -d. -f2)
        
        if [ "$NVIM_MAJOR" -lt 1 ] && [ "$NVIM_MINOR" -lt 8 ]; then
            echo -e "${YELLOW}  ⚠ Neovim v$NVIM_VERSION detected (LazyVim needs >= 0.8.0)${NC}"
            echo -e "${YELLOW}  Creating basic config instead of LazyVim${NC}"
            mkdir -p "$HOME/.config/nvim/lua/config"
        else
            # Install LazyVim
            show_loading "Setting up LazyVim"
            if git clone https://github.com/LazyVim/starter "$HOME/.config/nvim" > /dev/null 2>&1; then
                # Remove .git folder to make it your own
                rm -rf "$HOME/.config/nvim/.git" 2>/dev/null || true
                stop_loading
            else
                stop_loading
                echo -e "${YELLOW}  LazyVim clone failed, creating basic Neovim config${NC}"
                mkdir -p "$HOME/.config/nvim/lua/config"
            fi
        fi
    else
        echo -e "${YELLOW}  Neovim not found, creating basic config${NC}"
        mkdir -p "$HOME/.config/nvim/lua/config"
    fi
    
    # Create a simple init configuration
    cat > "$HOME/.config/nvim/lua/config/options.lua" << 'LAZYVIM'
-- AKAOIO LazyVim Configuration
vim.g.mapleader = " "
vim.g.maplocalleader = ","

local opt = vim.opt

opt.autowrite = true
opt.clipboard = "unnamedplus"
opt.completeopt = "menu,menuone,noselect"
opt.conceallevel = 3
opt.confirm = true
opt.cursorline = true
opt.expandtab = true
opt.formatoptions = "jcroqlnt"
opt.grepformat = "%f:%l:%c:%m"
opt.grepprg = "rg --vimgrep"
opt.ignorecase = true
opt.inccommand = "nosplit"
opt.laststatus = 0
opt.list = true
opt.mouse = "a"
opt.number = true
opt.pumblend = 10
opt.pumheight = 10
opt.relativenumber = true
opt.scrolloff = 4
opt.sessionoptions = { "buffers", "curdir", "tabpages", "winsize" }
opt.shiftround = true
opt.shiftwidth = 2
opt.shortmess:append({ W = true, I = true, c = true })
opt.showmode = false
opt.sidescrolloff = 8
opt.signcolumn = "yes"
opt.smartcase = true
opt.smartindent = true
opt.spelllang = { "en" }
opt.splitbelow = true
opt.splitright = true
opt.tabstop = 2
opt.termguicolors = true
opt.timeoutlen = 300
opt.undofile = true
opt.undolevels = 10000
opt.updatetime = 200
opt.wildmode = "longest:full,full"
opt.winminwidth = 5
opt.wrap = false
LAZYVIM
    stop_loading
    
    echo -e "${GREEN}✓ LazyVim installed${NC}"
    echo -e "${YELLOW}  First launch will install plugins automatically${NC}"
    sleep 1
}

# Configure Zsh
configure_zsh() {
    echo -e "${BLUE}▸ Configuring terminal${NC}"
    
    show_loading "Creating .zshrc configuration"
    
    # Create .zshrc
    cat > "$HOME/.zshrc" << 'ZSHRC'
# AKAOIO TERMINAL - CYBERPUNK ZSH

# Enable Powerlevel10k instant prompt
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Add Homebrew to PATH if installed (for immutable systems)
if [ -d "/home/linuxbrew/.linuxbrew" ]; then
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
elif [ -d "/opt/homebrew" ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Path to Oh My Zsh
export ZSH="$HOME/.oh-my-zsh"

# Theme
ZSH_THEME="powerlevel10k/powerlevel10k"

# Terminal Theme System
# Load saved theme preference first
if [ -f ~/.terminal-theme ]; then
    source ~/.terminal-theme
else
    export TERMINAL_THEME="${TERMINAL_THEME:-cyberpunk}"
fi

# Load theme colors
if [ -f "$HOME/.config/terminal/theme/load.sh" ]; then
    source "$HOME/.config/terminal/theme/load.sh" "$TERMINAL_THEME" 2>/dev/null
fi

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

# ZSH SYNTAX HIGHLIGHTING - Dracula Theme Colors
# These colors ensure command input matches the Dracula color scheme
typeset -A ZSH_HIGHLIGHT_STYLES
ZSH_HIGHLIGHT_STYLES[default]='fg=#f8f8f2'                      # Default text - white
ZSH_HIGHLIGHT_STYLES[unknown-token]='fg=#ff5555,bold'           # Unknown - red
ZSH_HIGHLIGHT_STYLES[reserved-word]='fg=#ff79c6'                # Reserved words - pink
ZSH_HIGHLIGHT_STYLES[alias]='fg=#50fa7b'                        # Aliases - green
ZSH_HIGHLIGHT_STYLES[suffix-alias]='fg=#50fa7b'                 # Suffix aliases - green
ZSH_HIGHLIGHT_STYLES[global-alias]='fg=#50fa7b'                 # Global aliases - green
ZSH_HIGHLIGHT_STYLES[builtin]='fg=#8be9fd'                      # Builtins - cyan
ZSH_HIGHLIGHT_STYLES[function]='fg=#50fa7b'                     # Functions - green
ZSH_HIGHLIGHT_STYLES[command]='fg=#8be9fd'                      # Commands - cyan
ZSH_HIGHLIGHT_STYLES[precommand]='fg=#50fa7b,underline'         # Precommands - green underlined
ZSH_HIGHLIGHT_STYLES[commandseparator]='fg=#ff79c6'             # Command separators - pink
ZSH_HIGHLIGHT_STYLES[hashed-command]='fg=#8be9fd'               # Hashed commands - cyan
ZSH_HIGHLIGHT_STYLES[autodirectory]='fg=#ffb86c,underline'      # Auto directories - orange
ZSH_HIGHLIGHT_STYLES[path]='fg=#f8f8f2,underline'               # Paths - white underlined
ZSH_HIGHLIGHT_STYLES[path_pathseparator]='fg=#ff79c6'           # Path separators - pink
ZSH_HIGHLIGHT_STYLES[path_prefix]='fg=#f8f8f2,underline'        # Path prefix - white underlined
ZSH_HIGHLIGHT_STYLES[path_prefix_pathseparator]='fg=#ff79c6'    # Path prefix separators - pink
ZSH_HIGHLIGHT_STYLES[globbing]='fg=#8be9fd'                     # Globbing - cyan
ZSH_HIGHLIGHT_STYLES[history-expansion]='fg=#bd93f9'            # History expansion - purple
ZSH_HIGHLIGHT_STYLES[command-substitution]='fg=#f1fa8c'         # Command substitution - yellow
ZSH_HIGHLIGHT_STYLES[command-substitution-unquoted]='fg=#f1fa8c' # Unquoted substitution - yellow
ZSH_HIGHLIGHT_STYLES[command-substitution-delimiter]='fg=#ff79c6' # Substitution delimiters - pink
ZSH_HIGHLIGHT_STYLES[process-substitution]='fg=#f1fa8c'         # Process substitution - yellow
ZSH_HIGHLIGHT_STYLES[process-substitution-delimiter]='fg=#ff79c6' # Process delimiters - pink
ZSH_HIGHLIGHT_STYLES[arithmetic-expansion]='fg=#bd93f9'         # Arithmetic - purple
ZSH_HIGHLIGHT_STYLES[single-hyphen-option]='fg=#ffb86c'         # Single hyphen options - orange
ZSH_HIGHLIGHT_STYLES[double-hyphen-option]='fg=#ffb86c'         # Double hyphen options - orange
ZSH_HIGHLIGHT_STYLES[back-quoted-argument]='fg=#bd93f9'         # Back quotes - purple
ZSH_HIGHLIGHT_STYLES[back-quoted-argument-unclosed]='fg=#ff5555' # Unclosed back quotes - red
ZSH_HIGHLIGHT_STYLES[back-quoted-argument-delimiter]='fg=#ff79c6' # Back quote delimiters - pink
ZSH_HIGHLIGHT_STYLES[single-quoted-argument]='fg=#f1fa8c'       # Single quotes - yellow
ZSH_HIGHLIGHT_STYLES[single-quoted-argument-unclosed]='fg=#ff5555' # Unclosed single quotes - red
ZSH_HIGHLIGHT_STYLES[double-quoted-argument]='fg=#f1fa8c'       # Double quotes - yellow
ZSH_HIGHLIGHT_STYLES[double-quoted-argument-unclosed]='fg=#ff5555' # Unclosed double quotes - red
ZSH_HIGHLIGHT_STYLES[dollar-quoted-argument]='fg=#f1fa8c'       # Dollar quotes - yellow
ZSH_HIGHLIGHT_STYLES[dollar-quoted-argument-unclosed]='fg=#ff5555' # Unclosed dollar quotes - red
ZSH_HIGHLIGHT_STYLES[rc-quote]='fg=#f1fa8c'                     # RC quotes - yellow
ZSH_HIGHLIGHT_STYLES[dollar-double-quoted-argument]='fg=#bd93f9' # Dollar double quotes - purple
ZSH_HIGHLIGHT_STYLES[back-double-quoted-argument]='fg=#bd93f9'  # Back double quotes - purple
ZSH_HIGHLIGHT_STYLES[back-dollar-quoted-argument]='fg=#bd93f9'  # Back dollar quotes - purple
ZSH_HIGHLIGHT_STYLES[assign]='fg=#f8f8f2'                       # Assignments - white
ZSH_HIGHLIGHT_STYLES[redirection]='fg=#ff79c6'                  # Redirections - pink
ZSH_HIGHLIGHT_STYLES[comment]='fg=#6272a4'                      # Comments - gray
ZSH_HIGHLIGHT_STYLES[named-fd]='fg=#f8f8f2'                     # Named file descriptors - white
ZSH_HIGHLIGHT_STYLES[numeric-fd]='fg=#f8f8f2'                   # Numeric file descriptors - white
ZSH_HIGHLIGHT_STYLES[arg0]='fg=#50fa7b'                         # First argument - green

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

# Beautiful LS_COLORS - Dracula theme
export LS_COLORS='di=38;2;139;233;253:ln=38;2;255;121;198:so=38;2;80;250;123:pi=38;2;241;250;140:ex=38;2;255;85;85:bd=38;2;139;233;253:cd=38;2;139;233;253:su=38;2;248;248;242:sg=38;2;248;248;242:tw=38;2;248;248;242:ow=38;2;248;248;242:*.tar=38;2;255;121;198:*.tgz=38;2;255;121;198:*.zip=38;2;255;121;198:*.gz=38;2;255;121;198:*.bz2=38;2;255;121;198:*.xz=38;2;255;121;198:*.7z=38;2;255;121;198:*.rar=38;2;255;121;198:*.deb=38;2;255;121;198:*.rpm=38;2;255;121;198:*.jar=38;2;255;121;198:*.jpg=38;2;189;147;249:*.jpeg=38;2;189;147;249:*.png=38;2;189;147;249:*.gif=38;2;189;147;249:*.bmp=38;2;189;147;249:*.svg=38;2;189;147;249:*.tiff=38;2;189;147;249:*.ico=38;2;189;147;249:*.mp4=38;2;241;250;140:*.mov=38;2;241;250;140:*.avi=38;2;241;250;140:*.mkv=38;2;241;250;140:*.webm=38;2;241;250;140:*.mp3=38;2;80;250;123:*.wav=38;2;80;250;123:*.flac=38;2;80;250;123:*.aac=38;2;80;250;123:*.ogg=38;2;80;250;123:*.js=38;2;241;250;140:*.jsx=38;2;241;250;140:*.ts=38;2;139;233;253:*.tsx=38;2;139;233;253:*.json=38;2;241;250;140:*.css=38;2;189;147;249:*.scss=38;2;189;147;249:*.html=38;2;255;85;85:*.htm=38;2;255;85;85:*.xml=38;2;255;85;85:*.md=38;2;248;248;242:*.txt=38;2;248;248;242:*.log=38;2;98;114;164:*.py=38;2;139;233;253:*.go=38;2;139;233;253:*.rs=38;2;255;85;85:*.java=38;2;241;250;140:*.c=38;2;80;250;123:*.cpp=38;2;80;250;123:*.h=38;2;80;250;123:*.hpp=38;2;80;250;123:*.rb=38;2;255;85;85:*.php=38;2;139;233;253:*.sh=38;2;80;250;123:*.yml=38;2;241;250;140:*.yaml=38;2;241;250;140:*.toml=38;2;241;250;140:*.ini=38;2;241;250;140:*.conf=38;2;241;250;140:*.cfg=38;2;241;250;140:'

# EXA colors for Dracula theme - consistent and beautiful
export EXA_COLORS='da=38;2;98;114;164:di=38;2;139;233;253:ex=38;2;255;85;85:fi=38;2;248;248;242:ln=38;2;255;121;198:bd=38;2;139;233;253:cd=38;2;139;233;253:pi=38;2;241;250;140:so=38;2;80;250;123:uu=38;2;80;250;123:gu=38;2;241;250;140:ur=38;2;255;85;85:uw=38;2;139;233;253:ux=38;2;189;147;249:ue=38;2;139;233;253:gr=38;2;241;250;140:gw=38;2;139;233;253:gx=38;2;189;147;249:tr=38;2;255;85;85:tw=38;2;139;233;253:tx=38;2;189;147;249:*.js=38;2;241;250;140:*.jsx=38;2;241;250;140:*.ts=38;2;139;233;253:*.tsx=38;2;139;233;253:*.json=38;2;241;250;140:*.css=38;2;189;147;249:*.scss=38;2;189;147;249:*.html=38;2;255;85;85:*.htm=38;2;255;85;85:*.xml=38;2;255;85;85:*.md=38;2;248;248;242:*.txt=38;2;248;248;242:*.log=38;2;98;114;164:*.py=38;2;139;233;253:*.go=38;2;139;233;253:*.rs=38;2;255;85;85:*.java=38;2;241;250;140:*.c=38;2;80;250;123:*.cpp=38;2;80;250;123:*.h=38;2;80;250;123:*.hpp=38;2;80;250;123:'

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

# Claude CLI aliases (override system cc compiler)
unalias cc 2>/dev/null
unalias dex 2>/dev/null
alias cc='claude --dangerously-skip-permissions'
alias dex='claude --dangerously-skip-permissions'

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

# AKAOIO DEX - Smart tmux workspace
alias dex='$HOME/.local/bin/dex'
alias dx='dex'
alias tmux-kill='tmux kill-server'
alias tks='tmux kill-session -t'
alias tls='tmux list-sessions'
alias ta='tmux attach -t'
alias tn='tmux new -s'

# Claude Code AI Assistant
alias cc='claude --dangerously-skip-permissions'

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
fdir() {
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

# Theme management functions
theme() {
    local theme_cmd="${1:-list}"
    local theme_dir="$HOME/.config/terminal/theme"
    
    # Check if theme system is installed in config directory
    if [ ! -f "$theme_dir/cli.sh" ]; then
        # Try development directory
        if [ -f "$HOME/Projects/terminal/theme/cli.sh" ]; then
            theme_dir="$HOME/Projects/terminal/theme"
        else
            echo "Theme system not installed. Run the installer first."
            return 1
        fi
    fi
    
    case "$theme_cmd" in
        list)
            "$theme_dir/cli.sh" list
            ;;
        set)
            if [ -z "$2" ]; then
                echo "Usage: theme set <name>"
                return 1
            fi
            
            local THEME_NAME="$2"
            
            # Validate theme exists
            if [ ! -f "$theme_dir/data/${THEME_NAME}.json" ]; then
                echo "Error: Theme '$THEME_NAME' not found"
                echo "Available themes: dracula, cyberpunk, nord, gruvbox"
                return 1
            fi
            
            # Save preference first
            "$theme_dir/cli.sh" set "$THEME_NAME" > /dev/null 2>&1
            export TERMINAL_THEME="$THEME_NAME"
            
            # Apply colors dynamically using jq if available
            if command -v jq &> /dev/null; then
                # Get colors from JSON using jq
                local purple=$(jq -r '.colors.term.purple' "$theme_dir/data/${THEME_NAME}.json")
                local green=$(jq -r '.colors.term.green' "$theme_dir/data/${THEME_NAME}.json")
                local cyan=$(jq -r '.colors.term.cyan' "$theme_dir/data/${THEME_NAME}.json")
                local pink=$(jq -r '.colors.term.pink' "$theme_dir/data/${THEME_NAME}.json")
                local yellow=$(jq -r '.colors.term.yellow' "$theme_dir/data/${THEME_NAME}.json")
                local red=$(jq -r '.colors.term.red' "$theme_dir/data/${THEME_NAME}.json")
                local blue=$(jq -r '.colors.term.blue' "$theme_dir/data/${THEME_NAME}.json")
                
                # Generate LS_COLORS based on theme's actual colors
                case "$THEME_NAME" in
                    dracula)
                        export LS_COLORS="di=1;${purple}:ln=1;${cyan}:so=1;${green}:pi=${yellow}:ex=1;${pink}:bd=${blue};46:cd=${blue};43:su=30;41:sg=30;46:tw=30;42:ow=30;43"
                        export BAT_THEME="Dracula"
                        ;;
                    cyberpunk)
                        export LS_COLORS="di=1;${pink}:ln=1;${cyan}:so=1;${green}:pi=1;${yellow}:ex=1;${green}:bd=1;${red}:cd=1;${red}:su=1;97;41:sg=1;97;44:tw=1;97;42:ow=1;97;43"
                        export BAT_THEME="TwoDark"
                        ;;
                    nord)
                        export LS_COLORS="di=1;${blue}:ln=1;${cyan}:so=1;${purple}:pi=${yellow}:ex=1;${green}:bd=${blue};46:cd=${blue};43:su=30;41:sg=30;46:tw=30;42:ow=30;43"
                        export BAT_THEME="Nord"
                        ;;
                    gruvbox)
                        export LS_COLORS="di=1;${yellow}:ln=1;${cyan}:so=1;${purple}:pi=${yellow}:ex=1;${green}:bd=${blue};46:cd=${blue};43:su=30;41:sg=30;46:tw=30;42:ow=30;43"
                        export BAT_THEME="gruvbox-dark"
                        ;;
                esac
                
                # Generate EXA_COLORS dynamically
                export EXA_COLORS="di=1;${purple}:ex=1;${green}:ln=1;${cyan}:*.md=1;${yellow}:*.json=1;${blue}:*.js=1;${green}:*.ts=1;${green}:*.sh=1;${red}"
            else
                # Fallback if jq not available - still hardcoded but at least works
                case "$THEME_NAME" in
                    dracula)
                        export LS_COLORS="di=1;35:ln=1;36:so=1;32:pi=33:ex=1;35:bd=34;46:cd=34;43:su=30;41:sg=30;46:tw=30;42:ow=30;43"
                        export BAT_THEME="Dracula"
                        ;;
                    cyberpunk)
                        export LS_COLORS="di=1;95:ln=1;96:so=1;92:pi=1;93:ex=1;92:bd=1;91:cd=1;91:su=1;97;41:sg=1;97;44:tw=1;97;42:ow=1;97;43"
                        export BAT_THEME="TwoDark"
                        ;;
                    nord)
                        export LS_COLORS="di=1;34:ln=1;36:so=1;35:pi=33:ex=1;32:bd=34;46:cd=34;43:su=30;41:sg=30;46:tw=30;42:ow=30;43"
                        export BAT_THEME="Nord"
                        ;;
                    gruvbox)
                        export LS_COLORS="di=1;33:ln=1;36:so=1;35:pi=33:ex=1;32:bd=34;46:cd=34;43:su=30;41:sg=30;46:tw=30;42:ow=30;43"
                        export BAT_THEME="gruvbox-dark"
                        ;;
                esac
            fi
            
            # Note: ZSH syntax highlighting can't be changed dynamically
            # It requires restart to apply properly
            
            echo "✓ Theme changed to: $THEME_NAME"
            echo ""
            echo "Applied immediately:"
            echo "  • File colors (ls/exa)"
            echo "  • BAT syntax highlighting"
            echo ""
            echo "To update syntax highlighting colors:"
            echo "  Run: exec zsh"
            ;;
        get|current)
            "$theme_dir/cli.sh" get | grep '"name"' | cut -d'"' -f4
            ;;
        *)
            echo "Usage: theme [list|set <name>|get]"
            ;;
    esac
}

# Quick theme switcher aliases
alias theme-dracula='theme set dracula'
alias theme-cyberpunk='theme set cyberpunk'
alias theme-nord='theme set nord'
alias theme-gruvbox='theme set gruvbox'

# Theme reload function (applies current theme colors)
theme-reload() {
    local current_theme="${TERMINAL_THEME:-cyberpunk}"
    local theme_dir="$HOME/.config/terminal/theme"
    
    if [ -f "$theme_dir/switch.sh" ]; then
        source "$theme_dir/switch.sh" "$current_theme"
    else
        echo "Theme system not installed"
    fi
}

# Apply theme colors on shell startup (theme preference already loaded above)
if [ -n "$TERMINAL_THEME" ]; then
    # Apply the theme using the same logic as theme set
    case "$TERMINAL_THEME" in
        dracula)
            export LS_COLORS="di=1;35:ln=1;36:so=1;32:pi=33:ex=1;35:bd=34;46:cd=34;43:su=30;41:sg=30;46:tw=30;42:ow=30;43"
            export EXA_COLORS="di=1;35:ex=1;35:ln=1;36:*.md=1;33:*.json=1;34:*.js=1;32:*.ts=1;32:*.sh=1;31"
            export BAT_THEME="Dracula"
            ;;
        cyberpunk)
            export LS_COLORS="di=1;95:ln=1;96:so=1;92:pi=1;93:ex=1;92:bd=1;91:cd=1;91:su=1;97;41:sg=1;97;44:tw=1;97;42:ow=1;97;43"
            export EXA_COLORS="di=1;95:ex=1;92:ln=1;96:*.md=1;93:*.json=1;94:*.js=1;92:*.ts=1;92:*.sh=1;91"
            export BAT_THEME="TwoDark"
            ;;
        nord)
            export LS_COLORS="di=1;34:ln=1;36:so=1;35:pi=33:ex=1;32:bd=34;46:cd=34;43:su=30;41:sg=30;46:tw=30;42:ow=30;43"
            export EXA_COLORS="di=1;34:ex=1;32:ln=1;36:*.md=1;33:*.json=1;34:*.js=1;32:*.ts=1;32:*.sh=1;31"
            export BAT_THEME="Nord"
            ;;
        gruvbox)
            export LS_COLORS="di=1;33:ln=1;36:so=1;35:pi=33:ex=1;32:bd=34;46:cd=34;43:su=30;41:sg=30;46:tw=30;42:ow=30;43"
            export EXA_COLORS="di=1;33:ex=1;32:ln=1;36:*.md=1;33:*.json=1;34:*.js=1;32:*.ts=1;32:*.sh=1;31"
            export BAT_THEME="gruvbox-dark"
            ;;
    esac
    
    # Apply ZSH syntax highlighting if plugin is loaded
    if [ -n "$ZSH_VERSION" ] && [ -n "${ZSH_HIGHLIGHT_STYLES+x}" ]; then
        case "$TERMINAL_THEME" in
            dracula)
                ZSH_HIGHLIGHT_STYLES[default]='fg=248'
                ZSH_HIGHLIGHT_STYLES[command]='fg=141'
                ZSH_HIGHLIGHT_STYLES[builtin]='fg=212'
                ZSH_HIGHLIGHT_STYLES[function]='fg=84'
                ZSH_HIGHLIGHT_STYLES[alias]='fg=84'
                ;;
            cyberpunk)
                ZSH_HIGHLIGHT_STYLES[default]='fg=15'
                ZSH_HIGHLIGHT_STYLES[command]='fg=198'
                ZSH_HIGHLIGHT_STYLES[builtin]='fg=51'
                ZSH_HIGHLIGHT_STYLES[function]='fg=46'
                ZSH_HIGHLIGHT_STYLES[alias]='fg=226'
                ;;
            nord)
                ZSH_HIGHLIGHT_STYLES[default]='fg=252'
                ZSH_HIGHLIGHT_STYLES[command]='fg=81'
                ZSH_HIGHLIGHT_STYLES[builtin]='fg=139'
                ZSH_HIGHLIGHT_STYLES[function]='fg=109'
                ZSH_HIGHLIGHT_STYLES[alias]='fg=109'
                ;;
            gruvbox)
                ZSH_HIGHLIGHT_STYLES[default]='fg=223'
                ZSH_HIGHLIGHT_STYLES[command]='fg=142'
                ZSH_HIGHLIGHT_STYLES[builtin]='fg=167'
                ZSH_HIGHLIGHT_STYLES[function]='fg=109'
                ZSH_HIGHLIGHT_STYLES[alias]='fg=108'
                ;;
        esac
    fi
fi

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
    
    # Use unified P10k config for all environments
    cp "$SCRIPT_DIR/configs/p10k.zsh" "$HOME/.p10k.zsh" 2>/dev/null || \
    curl -fsSL https://raw.githubusercontent.com/akaoio/terminal/main/configs/p10k.zsh -o "$HOME/.p10k.zsh" 2>/dev/null || \
    create_default_p10k_config
    
    # Configure neofetch for minimal display
    mkdir -p "$HOME/.config/neofetch"
    cp "$SCRIPT_DIR/configs/neofetch.conf" "$HOME/.config/neofetch/config.conf" 2>/dev/null || \
    curl -fsSL https://raw.githubusercontent.com/akaoio/terminal/main/configs/neofetch.conf -o "$HOME/.config/neofetch/config.conf" 2>/dev/null || \
    create_minimal_neofetch_config
    
    echo -e "${GREEN}  ✓ Configuration complete${NC}"
    sleep 1
}

# Create minimal neofetch config
create_minimal_neofetch_config() {
    mkdir -p "$HOME/.config/neofetch"
    cat > "$HOME/.config/neofetch/config.conf" << 'NEOFETCH'
# Minimal Neofetch Config
image_backend="off"
print_info() {
    info "OS" distro
    info "Shell" shell  
    info "Terminal" term
    info "CPU" cpu
    info "Memory" memory
}
NEOFETCH
}

# Universal P10k config for all environments with DYNAMIC THEME SUPPORT
create_default_p10k_config() {
    cat > "$HOME/.p10k.zsh" << 'P10K'
# AKAOIO Terminal - Dynamic Theme Support
# Format: user@host ~/dir (git) > 

'builtin' 'local' '-a' 'p10k_config_opts'
[[ ! -o 'aliases'         ]] || p10k_config_opts+=('aliases')
[[ ! -o 'sh_glob'         ]] || p10k_config_opts+=('sh_glob')
[[ ! -o 'no_brace_expand' ]] || p10k_config_opts+=('no_brace_expand')
'builtin' 'setopt' 'no_aliases' 'no_sh_glob' 'brace_expand'

() {
  emulate -L zsh -o extended_glob
  unset -m '(POWERLEVEL9K_*|DEFAULT_USER)~POWERLEVEL9K_GITSTATUS_DIR'
  [[ $ZSH_VERSION == (5.<1->*|<6->.*) ]] || return

  # Get current theme (default to dracula)
  local current_theme="${TERMINAL_THEME:-dracula}"
  
  # Disable all icons for Termux compatibility
  typeset -g POWERLEVEL9K_MODE='compatible'
  typeset -g POWERLEVEL9K_VISUAL_IDENTIFIER_EXPANSION=
  
  # Simple one-line prompt
  typeset -g POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(
    context                 # user@hostname
    dir                     # current directory  
    vcs                     # git status
    prompt_char            # > 
  )

  typeset -g POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=()

  # Basic settings - ONE LINE, no backgrounds anywhere
  typeset -g POWERLEVEL9K_PROMPT_ON_NEWLINE=false
  typeset -g POWERLEVEL9K_PROMPT_ADD_NEWLINE=false
  typeset -g POWERLEVEL9K_BACKGROUND=                 # global no background
  
  # Dynamic theme colors based on $TERMINAL_THEME
  case "$current_theme" in
    dracula)
      # Dracula colors - no backgrounds, text only
      typeset -g POWERLEVEL9K_CONTEXT_FOREGROUND='#BD93F9'  # purple text
      typeset -g POWERLEVEL9K_DIR_FOREGROUND='#8BE9FD'      # cyan text
      typeset -g POWERLEVEL9K_VCS_CLEAN_FOREGROUND='#50FA7B'     # green text
      typeset -g POWERLEVEL9K_VCS_MODIFIED_FOREGROUND='#F1FA8C'  # yellow text
      typeset -g POWERLEVEL9K_VCS_UNTRACKED_FOREGROUND='#FFB86C' # orange text
      typeset -g POWERLEVEL9K_PROMPT_CHAR_OK_{VIINS,VICMD,VIVIS,VIOWR}_FOREGROUND='#FF79C6'    # pink
      typeset -g POWERLEVEL9K_PROMPT_CHAR_ERROR_{VIINS,VICMD,VIVIS,VIOWR}_FOREGROUND='#FF5555'  # red
      ;;
      
    cyberpunk)
      # Cyberpunk neon colors
      typeset -g POWERLEVEL9K_CONTEXT_FOREGROUND='#FF00FF'  # bright magenta
      typeset -g POWERLEVEL9K_DIR_FOREGROUND='#00FFFF'      # bright cyan
      typeset -g POWERLEVEL9K_VCS_CLEAN_FOREGROUND='#00FF00'     # bright green
      typeset -g POWERLEVEL9K_VCS_MODIFIED_FOREGROUND='#FFFF00'  # bright yellow
      typeset -g POWERLEVEL9K_VCS_UNTRACKED_FOREGROUND='#FF6600' # bright orange
      typeset -g POWERLEVEL9K_PROMPT_CHAR_OK_{VIINS,VICMD,VIVIS,VIOWR}_FOREGROUND='#FF00FF'    # bright magenta
      typeset -g POWERLEVEL9K_PROMPT_CHAR_ERROR_{VIINS,VICMD,VIVIS,VIOWR}_FOREGROUND='#FF0000'  # bright red
      ;;
      
    nord)
      # Nord cool colors
      typeset -g POWERLEVEL9K_CONTEXT_FOREGROUND='#81A1C1'  # nord9 blue
      typeset -g POWERLEVEL9K_DIR_FOREGROUND='#88C0D0'      # nord8 cyan
      typeset -g POWERLEVEL9K_VCS_CLEAN_FOREGROUND='#A3BE8C'     # nord14 green
      typeset -g POWERLEVEL9K_VCS_MODIFIED_FOREGROUND='#EBCB8B'  # nord13 yellow
      typeset -g POWERLEVEL9K_VCS_UNTRACKED_FOREGROUND='#D08770' # nord12 orange
      typeset -g POWERLEVEL9K_PROMPT_CHAR_OK_{VIINS,VICMD,VIVIS,VIOWR}_FOREGROUND='#B48EAD'    # nord15 purple
      typeset -g POWERLEVEL9K_PROMPT_CHAR_ERROR_{VIINS,VICMD,VIVIS,VIOWR}_FOREGROUND='#BF616A'  # nord11 red
      ;;
      
    gruvbox)
      # Gruvbox warm colors
      typeset -g POWERLEVEL9K_CONTEXT_FOREGROUND='#D3869B'  # purple
      typeset -g POWERLEVEL9K_DIR_FOREGROUND='#83A598'      # cyan/aqua
      typeset -g POWERLEVEL9K_VCS_CLEAN_FOREGROUND='#B8BB26'     # green
      typeset -g POWERLEVEL9K_VCS_MODIFIED_FOREGROUND='#FABD2F'  # yellow
      typeset -g POWERLEVEL9K_VCS_UNTRACKED_FOREGROUND='#FE8019' # orange
      typeset -g POWERLEVEL9K_PROMPT_CHAR_OK_{VIINS,VICMD,VIVIS,VIOWR}_FOREGROUND='#FB4934'    # bright red
      typeset -g POWERLEVEL9K_PROMPT_CHAR_ERROR_{VIINS,VICMD,VIVIS,VIOWR}_FOREGROUND='#CC241D'  # red
      ;;
      
    *)
      # Default fallback to dracula
      typeset -g POWERLEVEL9K_CONTEXT_FOREGROUND='#BD93F9'  # purple text
      typeset -g POWERLEVEL9K_DIR_FOREGROUND='#8BE9FD'      # cyan text
      typeset -g POWERLEVEL9K_VCS_CLEAN_FOREGROUND='#50FA7B'     # green text
      typeset -g POWERLEVEL9K_VCS_MODIFIED_FOREGROUND='#F1FA8C'  # yellow text
      typeset -g POWERLEVEL9K_VCS_UNTRACKED_FOREGROUND='#FFB86C' # orange text
      typeset -g POWERLEVEL9K_PROMPT_CHAR_OK_{VIINS,VICMD,VIVIS,VIOWR}_FOREGROUND='#FF79C6'    # pink
      typeset -g POWERLEVEL9K_PROMPT_CHAR_ERROR_{VIINS,VICMD,VIVIS,VIOWR}_FOREGROUND='#FF5555'  # red
      ;;
  esac
  
  # Common settings for all themes
  typeset -g POWERLEVEL9K_CONTEXT_BACKGROUND=           # no background
  typeset -g POWERLEVEL9K_CONTEXT_TEMPLATE='%n@%m'
  
  typeset -g POWERLEVEL9K_DIR_BACKGROUND=               # no background
  typeset -g POWERLEVEL9K_DIR_MAX_LENGTH=30
  
  typeset -g POWERLEVEL9K_VCS_CLEAN_BACKGROUND=              # no background
  typeset -g POWERLEVEL9K_VCS_MODIFIED_BACKGROUND=           # no background
  typeset -g POWERLEVEL9K_VCS_UNTRACKED_BACKGROUND=          # no background
  
  # Disable folder icons completely
  typeset -g POWERLEVEL9K_DIR_SHOW_WRITABLE=false
  typeset -g POWERLEVEL9K_DIR_CLASSES=()
  typeset -g POWERLEVEL9K_HOME_ICON=
  typeset -g POWERLEVEL9K_HOME_SUB_ICON=
  typeset -g POWERLEVEL9K_FOLDER_ICON=
  typeset -g POWERLEVEL9K_ETC_ICON=
  
  # Use ASCII characters for git
  typeset -g POWERLEVEL9K_VCS_GIT_ICON=
  typeset -g POWERLEVEL9K_VCS_GIT_GITHUB_ICON=
  typeset -g POWERLEVEL9K_VCS_BRANCH_ICON=
  typeset -g POWERLEVEL9K_VCS_STAGED_ICON='+'
  typeset -g POWERLEVEL9K_VCS_UNSTAGED_ICON='!'
  typeset -g POWERLEVEL9K_VCS_UNTRACKED_ICON='?'
  
  # ASCII prompt character - no background
  typeset -g POWERLEVEL9K_PROMPT_CHAR_BACKGROUND=            # no background
  typeset -g POWERLEVEL9K_PROMPT_CHAR_OK_VIINS_CONTENT_EXPANSION='>'
  typeset -g POWERLEVEL9K_PROMPT_CHAR_ERROR_VIINS_CONTENT_EXPANSION='>'
  typeset -g POWERLEVEL9K_PROMPT_CHAR_LEFT_PROMPT_LAST_SEGMENT_END_SYMBOL=''
  
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
        # Setup storage access (skip if already exists to avoid prompts)
        if [ ! -d "$HOME/storage" ]; then
            termux-setup-storage 2>/dev/null || true
        fi
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
    echo -e "${WHITE}    • tmux with Smart Layouts (dex command)${NC}"
    echo -e "${WHITE}    • LazyVim - Modern Neovim IDE${NC}"
    echo -e "${WHITE}    • Claude Code - AI Coding Assistant${NC}"
    echo -e "${WHITE}    • 60+ Useful Aliases & Functions${NC}"
    echo ""
    echo -e "${NEON_PURPLE}  ▸ KEYBOARD SHORTCUTS:${NC}"
    echo -e "${WHITE}    • Tab         → Auto-complete with FZF${NC}"
    echo -e "${WHITE}    • Ctrl+R      → Search command history${NC}"
    echo -e "${WHITE}    • Ctrl+Space  → Accept auto-suggestion${NC}"
    echo -e "${WHITE}    • Ctrl+T      → Find files${NC}"
    echo -e "${WHITE}    • Alt+C       → Navigate directories${NC}"
    echo -e "${WHITE}    • dex         → Smart tmux workspace${NC}"
    echo -e "${WHITE}    • claude      → AI coding assistant${NC}"
    echo -e "${WHITE}    • Ctrl+A      → tmux prefix key${NC}"
    echo -e "${WHITE}    • Ctrl+A h    → split horizontal (mobile-friendly)${NC}"
    echo -e "${WHITE}    • Ctrl+A v    → split vertical (mobile-friendly)${NC}"
    echo -e "${WHITE}    • Ctrl+A j/k  → navigate up/down panes${NC}"
    echo -e "${WHITE}    • Ctrl+A b/l  → navigate left/right panes${NC}"
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
    echo -e "${PURPLE}═══════════════════════════════════════════════════════════════════════${NC}"
    echo -e "${NEON_GREEN}         Welcome to the future of terminal experience!${NC}"
    echo -e "${PURPLE}═══════════════════════════════════════════════════════════════════════${NC}"
    echo ""
}

# Install and configure dex script
install_dex() {
    echo -e "${BLUE}▸ Installing dex smart workspace${NC}"
    
    # Create local bin directory
    mkdir -p "$HOME/.local/bin"
    
    # Copy dex script
    if [ -f "$SCRIPT_DIR/dex" ]; then
        # Remove existing file or symlink to avoid conflicts
        [ -e "$HOME/.local/bin/dex" ] && rm -f "$HOME/.local/bin/dex"
        cp "$SCRIPT_DIR/dex" "$HOME/.local/bin/dex"
    else
        # Download from repository if not local
        show_loading "Downloading dex script"
        curl -fsSL https://raw.githubusercontent.com/akaoio/terminal/main/dex -o "$HOME/.local/bin/dex" 2>/dev/null
        stop_loading
    fi
    
    # Make executable
    chmod +x "$HOME/.local/bin/dex"
    
    # Add to PATH if not already there
    if ! echo "$PATH" | grep -q "$HOME/.local/bin"; then
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.zshrc"
    fi
    
    echo -e "${GREEN}✓ dex installed${NC}"
    sleep 1
}

# Theme selection
select_theme() {
    echo -e "${CYAN}▸ Theme Selection${NC}"
    echo ""
    echo "Available themes:"
    echo "  1) Dracula (default) - Dark with vibrant colors"
    echo "  2) Cyberpunk - Neon and bright"
    echo "  3) Nord - Cool and subdued"
    echo "  4) Gruvbox - Warm and retro"
    echo ""
    
    # Check if theme provided via environment
    if [ -n "$TERMINAL_THEME" ]; then
        echo -e "${GREEN}Using theme: $TERMINAL_THEME${NC}"
        return 0
    fi
    
    # Auto-select default after timeout
    echo -n "Select theme [1-4] (auto-select in 5s): "
    
    # Read with timeout
    if read -t 5 -n 1 choice; then
        echo ""
        case "$choice" in
            1) export TERMINAL_THEME="dracula" ;;
            2) export TERMINAL_THEME="cyberpunk" ;;
            3) export TERMINAL_THEME="nord" ;;
            4) export TERMINAL_THEME="gruvbox" ;;
            *) export TERMINAL_THEME="dracula" ;;
        esac
    else
        echo ""
        export TERMINAL_THEME="dracula"
    fi
    
    echo -e "${GREEN}Theme selected: $TERMINAL_THEME${NC}"
    
    # Reload colors with selected theme
    if [ -f "$SCRIPT_DIR/theme/load.sh" ]; then
        source "$SCRIPT_DIR/theme/load.sh" "$TERMINAL_THEME" 2>/dev/null
    fi
    
    # Copy theme system to user config
    if [ -d "$SCRIPT_DIR/theme" ]; then
        echo -e "${CYAN}Installing theme system...${NC}"
        mkdir -p "$HOME/.config/terminal"
        cp -r "$SCRIPT_DIR/theme" "$HOME/.config/terminal/" 2>/dev/null || true
        echo -e "${GREEN}✓ Theme system installed${NC}"
    fi
    
    sleep 1
}

# Main installation flow
main() {
    print_banner
    select_theme
    backup_configs
    install_packages
    install_oh_my_zsh
    install_p10k
    install_plugins
    install_fonts
    install_tmux
    install_lazyvim
    install_claude_code
    configure_zsh
    install_dex
    set_default_shell
    show_complete
}

# Run main function
main

# Return to original directory and start new shell
cd "$ORIGINAL_DIR"
echo -e "${CYAN}Starting new Zsh shell in 3 seconds...${NC}"
sleep 3
exec zsh -l