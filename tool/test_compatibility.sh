#!/usr/bin/env bash
# Test script for multi-platform compatibility

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}=== TERMINAL COMPATIBILITY TEST ===${NC}\n"

# Test environment detection
echo -e "${YELLOW}Platform Detection:${NC}"
if [ -n "$TERMUX_VERSION" ] || [ -d "/data/data/com.termux" ]; then
    echo -e "${GREEN}✓ Termux detected${NC}"
elif [[ "$OSTYPE" == "darwin"* ]]; then
    echo -e "${GREEN}✓ macOS detected${NC}"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    echo -e "${GREEN}✓ Linux detected${NC}"
elif grep -qi microsoft /proc/version 2>/dev/null; then
    echo -e "${GREEN}✓ WSL detected${NC}"
else
    echo -e "${RED}✗ Unknown platform${NC}"
fi

# Test shell availability
echo -e "\n${YELLOW}Shell Availability:${NC}"
for shell in bash zsh sh; do
    if command -v $shell &> /dev/null; then
        echo -e "${GREEN}✓ $shell available${NC}"
    else
        echo -e "${RED}✗ $shell not found${NC}"
    fi
done

# Test Claude alias
echo -e "\n${YELLOW}Claude Aliases:${NC}"
if grep -q "alias cc='claude --dangerously-skip-permissions'" "$HOME/.zshrc" 2>/dev/null; then
    echo -e "${GREEN}✓ cc alias configured in .zshrc${NC}"
else
    echo -e "${YELLOW}⚠ cc alias not found in .zshrc${NC}"
fi

if grep -q "alias dex='claude --dangerously-skip-permissions'" "$HOME/.zshrc" 2>/dev/null; then
    echo -e "${YELLOW}⚠ dex configured as Claude alias (should be tmux script)${NC}"
elif [ -f "$HOME/.local/bin/dex" ]; then
    echo -e "${GREEN}✓ dex script installed${NC}"
else
    echo -e "${RED}✗ dex script not found${NC}"
fi

# Test tmux availability
echo -e "\n${YELLOW}tmux Status:${NC}"
if command -v tmux &> /dev/null; then
    echo -e "${GREEN}✓ tmux installed${NC}"
    if [ -f "$HOME/.tmux.conf" ]; then
        echo -e "${GREEN}✓ tmux config exists${NC}"
    else
        echo -e "${YELLOW}⚠ tmux config missing${NC}"
    fi
else
    echo -e "${RED}✗ tmux not installed${NC}"
fi

# Test Neovim/LazyVim
echo -e "\n${YELLOW}Neovim/LazyVim Status:${NC}"
if command -v nvim &> /dev/null; then
    NVIM_VERSION=$(nvim --version 2>/dev/null | head -1 | grep -o 'v[0-9]\+\.[0-9]\+' | cut -c2-)
    echo -e "${GREEN}✓ Neovim installed (v$NVIM_VERSION)${NC}"
    
    if [ -d "$HOME/.config/nvim" ]; then
        if [ -d "$HOME/.config/nvim/.git" ] || [ -f "$HOME/.config/nvim/init.lua" ]; then
            echo -e "${GREEN}✓ LazyVim config exists${NC}"
        else
            echo -e "${YELLOW}⚠ Basic nvim config (not LazyVim)${NC}"
        fi
    else
        echo -e "${YELLOW}⚠ No nvim config found${NC}"
    fi
else
    echo -e "${RED}✗ Neovim not installed${NC}"
fi

# Test Claude Code
echo -e "\n${YELLOW}Claude Code Status:${NC}"
if command -v claude &> /dev/null; then
    echo -e "${GREEN}✓ Claude CLI installed${NC}"
else
    echo -e "${RED}✗ Claude CLI not found${NC}"
fi

# Test critical tools
echo -e "\n${YELLOW}Essential Tools:${NC}"
for tool in git curl wget; do
    if command -v $tool &> /dev/null; then
        echo -e "${GREEN}✓ $tool available${NC}"
    else
        echo -e "${RED}✗ $tool missing${NC}"
    fi
done

# Test enhanced tools
echo -e "\n${YELLOW}Enhanced Tools:${NC}"
for tool in fzf bat ripgrep fd exa; do
    if command -v $tool &> /dev/null; then
        echo -e "${GREEN}✓ $tool installed${NC}"
    else
        echo -e "${YELLOW}⚠ $tool not installed (optional)${NC}"
    fi
done

echo -e "\n${BLUE}=== TEST COMPLETE ===${NC}"