#!/usr/bin/env bash
# FORCE SYNC ALL CONFIGS FROM REPO
# This will OVERWRITE all local configs with repo versions

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

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