#!/usr/bin/env bash
# Helper script to install latest Neovim on any platform
# Ensures version >= 0.8.0 for LazyVim compatibility

set -e

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

# Detect platform
detect_platform() {
    if [ -n "$TERMUX_VERSION" ] || [ -d "/data/data/com.termux" ]; then
        echo "termux"
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        echo "macos"
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if command -v apt-get &> /dev/null; then
            echo "debian"
        elif command -v dnf &> /dev/null; then
            echo "redhat"
        elif command -v pacman &> /dev/null; then
            echo "arch"
        elif command -v apk &> /dev/null; then
            echo "alpine"
        else
            echo "linux"
        fi
    else
        echo "unknown"
    fi
}

# Get architecture
get_arch() {
    local arch=$(uname -m)
    case "$arch" in
        x86_64) echo "x86_64" ;;
        aarch64|arm64) echo "aarch64" ;;
        armv7l) echo "armv7l" ;;
        *) echo "$arch" ;;
    esac
}

# Install latest Neovim
install_neovim_latest() {
    local platform=$(detect_platform)
    local arch=$(get_arch)
    
    echo -e "${BLUE}Installing latest Neovim for $platform ($arch)...${NC}"
    
    case "$platform" in
        termux)
            # Termux always has recent version
            pkg update -y
            pkg install -y neovim nodejs-lts python
            ;;
            
        debian)
            # Try multiple methods in order of preference
            echo -e "${YELLOW}Trying to install latest Neovim...${NC}"
            
            # Method 1: Download pre-built binary (fastest, always latest)
            if [ "$arch" = "x86_64" ]; then
                echo -e "${BLUE}Downloading Neovim v0.10.2 binary...${NC}"
                wget -q https://github.com/neovim/neovim/releases/download/v0.10.2/nvim-linux64.tar.gz -O /tmp/nvim.tar.gz
                if [ $? -eq 0 ]; then
                    sudo tar -xzf /tmp/nvim.tar.gz -C /opt/
                    sudo ln -sf /opt/nvim-linux64/bin/nvim /usr/local/bin/nvim
                    rm /tmp/nvim.tar.gz
                    echo -e "${GREEN}✓ Neovim v0.10.2 installed${NC}"
                    return 0
                fi
            fi
            
            # Method 2: AppImage (universal, always latest)
            echo -e "${BLUE}Trying AppImage...${NC}"
            wget -q https://github.com/neovim/neovim/releases/latest/download/nvim.appimage -O /tmp/nvim.appimage
            if [ $? -eq 0 ]; then
                chmod +x /tmp/nvim.appimage
                # Extract AppImage instead of running directly (more reliable)
                cd /tmp
                ./nvim.appimage --appimage-extract >/dev/null 2>&1
                sudo mv squashfs-root /opt/nvim
                sudo ln -sf /opt/nvim/AppRun /usr/local/bin/nvim
                cd - >/dev/null
                rm -f /tmp/nvim.appimage
                echo -e "${GREEN}✓ Neovim AppImage installed${NC}"
                return 0
            fi
            
            # Method 3: Build from source (guaranteed latest)
            echo -e "${BLUE}Building from source...${NC}"
            sudo apt-get update
            sudo apt-get install -y ninja-build gettext cmake unzip curl build-essential
            
            cd /tmp
            git clone --depth 1 --branch stable https://github.com/neovim/neovim
            cd neovim
            make CMAKE_BUILD_TYPE=Release
            sudo make install
            cd ..
            rm -rf neovim
            echo -e "${GREEN}✓ Neovim built from source${NC}"
            ;;
            
        redhat)
            # Download pre-built binary for RHEL/Fedora
            if [ "$arch" = "x86_64" ]; then
                echo -e "${BLUE}Downloading Neovim binary...${NC}"
                wget -q https://github.com/neovim/neovim/releases/download/v0.10.2/nvim-linux64.tar.gz -O /tmp/nvim.tar.gz
                sudo tar -xzf /tmp/nvim.tar.gz -C /opt/
                sudo ln -sf /opt/nvim-linux64/bin/nvim /usr/local/bin/nvim
                rm /tmp/nvim.tar.gz
                echo -e "${GREEN}✓ Neovim v0.10.2 installed${NC}"
            else
                # Fallback to dnf/yum with EPEL
                sudo dnf install -y epel-release 2>/dev/null || sudo yum install -y epel-release
                sudo dnf install -y neovim || sudo yum install -y neovim
            fi
            ;;
            
        arch)
            # Arch always has latest
            sudo pacman -Syu --noconfirm neovim python-pynvim nodejs npm
            ;;
            
        macos)
            # Homebrew always has latest
            brew install neovim node python
            ;;
            
        alpine)
            # Alpine edge has latest
            echo "http://dl-cdn.alpinelinux.org/alpine/edge/community" | sudo tee -a /etc/apk/repositories
            sudo apk update
            sudo apk add neovim nodejs npm python3
            ;;
            
        *)
            echo -e "${RED}Unknown platform. Trying generic installation...${NC}"
            # Try to download binary
            if [ "$arch" = "x86_64" ]; then
                wget -q https://github.com/neovim/neovim/releases/download/v0.10.2/nvim-linux64.tar.gz -O /tmp/nvim.tar.gz
                tar -xzf /tmp/nvim.tar.gz -C $HOME/.local/
                ln -sf $HOME/.local/nvim-linux64/bin/nvim $HOME/.local/bin/nvim
                echo -e "${GREEN}✓ Neovim installed to ~/.local/bin${NC}"
            fi
            ;;
    esac
    
    # Install dependencies
    echo -e "${BLUE}Installing dependencies...${NC}"
    case "$platform" in
        debian)
            sudo apt-get install -y python3-neovim nodejs npm 2>/dev/null || true
            ;;
        redhat)
            sudo dnf install -y python3-neovim nodejs npm 2>/dev/null || \
            sudo yum install -y python3-neovim nodejs npm 2>/dev/null || true
            ;;
    esac
}

# Check current Neovim version
check_nvim_version() {
    if command -v nvim &> /dev/null; then
        local version=$(nvim --version | head -1 | grep -o '[0-9]\+\.[0-9]\+\.[0-9]\+' || echo "0.0.0")
        echo "$version"
    else
        echo "0.0.0"
    fi
}

# Main
main() {
    echo -e "${BLUE}=== Neovim Latest Installer ===${NC}\n"
    
    # Check current version
    current_version=$(check_nvim_version)
    echo -e "Current Neovim version: ${YELLOW}$current_version${NC}"
    
    # Parse version
    major=$(echo $current_version | cut -d. -f1)
    minor=$(echo $current_version | cut -d. -f2)
    
    # Check if update needed (need >= 0.8.0)
    if [ "$major" -eq 0 ] && [ "$minor" -lt 8 ]; then
        echo -e "${YELLOW}Version < 0.8.0, updating...${NC}\n"
        install_neovim_latest
    elif [ "$current_version" = "0.0.0" ]; then
        echo -e "${YELLOW}Neovim not found, installing...${NC}\n"
        install_neovim_latest
    else
        echo -e "${GREEN}✓ Neovim version is sufficient for LazyVim${NC}"
    fi
    
    # Final version check
    new_version=$(check_nvim_version)
    echo -e "\nFinal Neovim version: ${GREEN}$new_version${NC}"
    
    # Check if nvim is accessible
    if command -v nvim &> /dev/null; then
        echo -e "${GREEN}✓ Neovim is ready!${NC}"
        echo -e "${CYAN}Run 'nvim' to start${NC}"
    else
        echo -e "${YELLOW}⚠ Neovim installed but may need PATH update${NC}"
        echo -e "${CYAN}Add to PATH: export PATH=\"\$HOME/.local/bin:\$PATH\"${NC}"
    fi
}

main "$@"