#!/usr/bin/env bash
# FORCE SYNC ALL CONFIGS FROM REPO
# This will OVERWRITE all local configs with repo versions

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

echo -e "${RED}═════════════════════════════════════════${NC}"
echo -e "${RED}    FORCE SYNC - ALL CONFIGS WILL BE${NC}"
echo -e "${RED}       OVERWRITTEN FROM GITHUB!${NC}"
echo -e "${RED}═════════════════════════════════════════${NC}"
echo ""

# Get repo directory
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Pull latest from GitHub
echo -e "${BLUE}▸ Pulling latest from GitHub...${NC}"
cd "$SCRIPT_DIR"
git fetch origin
git reset --hard origin/main
echo -e "${GREEN}✓ Repository synced to latest${NC}"

# Force copy ALL configs
echo -e "${BLUE}▸ Force syncing all configurations...${NC}"

# P10k config
if [ -f "$SCRIPT_DIR/configs/p10k.zsh" ]; then
    cp -f "$SCRIPT_DIR/configs/p10k.zsh" "$HOME/.p10k.zsh"
    echo -e "${GREEN}  ✓ Powerlevel10k config overwritten${NC}"
fi

# tmux config
if [ -f "$SCRIPT_DIR/configs/tmux.conf" ]; then
    cp -f "$SCRIPT_DIR/configs/tmux.conf" "$HOME/.tmux.conf"
    echo -e "${GREEN}  ✓ tmux config overwritten${NC}"
fi

# dex script
if [ -f "$SCRIPT_DIR/dex" ]; then
    mkdir -p "$HOME/.local/bin"
    cp -f "$SCRIPT_DIR/dex" "$HOME/.local/bin/dex"
    chmod +x "$HOME/.local/bin/dex"
    echo -e "${GREEN}  ✓ dex script overwritten${NC}"
fi

# Regenerate .zshrc from install.sh
echo -e "${BLUE}▸ Regenerating .zshrc from template...${NC}"
if [ -f "$HOME/.zshrc" ]; then
    # Backup current
    cp "$HOME/.zshrc" "$HOME/.zshrc.backup-$(date +%Y%m%d-%H%M%S)"
    echo -e "${YELLOW}  Backup saved to .zshrc.backup-*${NC}"
fi

# Extract and regenerate .zshrc from install.sh
bash "$SCRIPT_DIR/install.sh" --regenerate-zshrc-only 2>/dev/null || {
    echo -e "${YELLOW}  Regenerating .zshrc manually...${NC}"
    # Create new .zshrc if install.sh doesn't support flag
    curl -fsSL https://raw.githubusercontent.com/akaoio/terminal/main/install.sh | \
        sed -n '/^cat > "\$HOME\/.zshrc" << '\''ZSHRC'\''/,/^ZSHRC$/p' | \
        sed '1d;$d' > "$HOME/.zshrc"
}

echo -e "${GREEN}  ✓ .zshrc regenerated from template${NC}"

# Reload shell
echo ""
echo -e "${GREEN}═════════════════════════════════════════${NC}"
echo -e "${GREEN}    FORCE SYNC COMPLETE!${NC}"
echo -e "${GREEN}═════════════════════════════════════════${NC}"
echo ""
echo -e "${YELLOW}All configs have been overwritten with${NC}"
echo -e "${YELLOW}the latest versions from GitHub.${NC}"
echo ""
echo -e "${CYAN}Run: exec zsh${NC} to reload shell"
echo ""