#!/usr/bin/env bash
# Debug installation issues - runs install with verbose output

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

echo -e "${CYAN}AKAOIO TERMINAL - DEBUG INSTALLER${NC}"
echo ""

# Test individual components
echo -e "${YELLOW}Testing LazyVim prerequisites:${NC}"

echo -n "Git available: "
if command -v git &> /dev/null; then
    echo -e "${GREEN}✓${NC}"
else
    echo -e "${RED}✗${NC}"
fi

echo -n "Internet connectivity: "
if curl -s --max-time 5 https://github.com > /dev/null; then
    echo -e "${GREEN}✓${NC}"
else
    echo -e "${RED}✗${NC}"
fi

echo -n "LazyVim repo accessible: "
if git ls-remote https://github.com/LazyVim/starter > /dev/null 2>&1; then
    echo -e "${GREEN}✓${NC}"
else
    echo -e "${RED}✗${NC}"
fi

echo -n "Neovim available: "
if command -v nvim &> /dev/null; then
    echo -e "${GREEN}✓ $(nvim --version | head -1)${NC}"
else
    echo -e "${YELLOW}- Not installed${NC}"
fi

echo ""
echo -e "${YELLOW}Testing Claude Code prerequisites:${NC}"

echo -n "Node.js available: "
if command -v node &> /dev/null; then
    echo -e "${GREEN}✓ $(node --version)${NC}"
else
    echo -e "${YELLOW}- Not installed${NC}"
fi

echo -n "NPM available: "
if command -v npm &> /dev/null; then
    echo -e "${GREEN}✓ $(npm --version)${NC}"
else
    echo -e "${YELLOW}- Not installed${NC}"
fi

echo -n "Claude installer accessible: "
if curl -s --max-time 5 https://claude.ai/install.sh > /dev/null; then
    echo -e "${GREEN}✓${NC}"
else
    echo -e "${RED}✗${NC}"
fi

echo ""
echo -e "${YELLOW}Environment info:${NC}"
echo "OS: $(uname -s)"
echo "Architecture: $(uname -m)"
echo "Shell: $SHELL"
echo "User: $USER"
echo "Home: $HOME"
echo "PWD: $PWD"

echo ""
echo -e "${BLUE}Running install with debug output...${NC}"
echo ""

# Run install with debug
export DISABLE_ANIMATIONS=1
bash -x ./install.sh 2>&1 | tee /tmp/install_debug.log || {
    echo ""
    echo -e "${RED}Installation failed!${NC}"
    echo -e "${YELLOW}Debug log saved to: /tmp/install_debug.log${NC}"
    echo ""
    echo -e "${CYAN}Last 20 lines of debug log:${NC}"
    tail -20 /tmp/install_debug.log
    exit 1
}

echo ""
echo -e "${GREEN}Installation completed successfully!${NC}"