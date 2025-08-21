#!/usr/bin/env bash
# DEX Enhanced UI Help - Part of AKAOIO Terminal Suite

# Dracula Theme Colors
CYAN='\033[38;5;117m'   # Dracula Cyan (#8be9fd)
PURPLE='\033[38;5;141m' # Dracula Purple (#bd93f9)
GREEN='\033[38;5;84m'   # Dracula Green (#50fa7b)
YELLOW='\033[38;5;228m' # Dracula Yellow (#f1fa8c)
PINK='\033[38;5;212m'   # Dracula Pink (#ff79c6)
NC='\033[0m'             # No Color

echo -e "${CYAN}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║                 DEX ENHANCED UI REFERENCE                   ║${NC}"
echo -e "${CYAN}╚══════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${PURPLE}🎯 UI LAYOUT:${NC}"
echo -e "  ${CYAN}▲ Status Bar:${NC}    Session info, windows, time"
echo -e "  ${GREEN}■ Work Area:${NC}     Main development panes"
echo ""
echo -e "${GREEN}UI CONTROLS:${NC}"
echo -e "  ${YELLOW}Ctrl-a + ?${NC}      This help popup"
echo ""
echo -e "${GREEN}QUICK POPUPS:${NC}"
echo -e "  ${YELLOW}Ctrl-a + Ctrl-s${NC} Session manager"
echo -e "  ${YELLOW}Ctrl-a + Ctrl-w${NC} Window manager"
echo -e "  ${YELLOW}Ctrl-a + Ctrl-p${NC} Pane manager"
echo ""
echo -e "${GREEN}NAVIGATION:${NC}"
echo -e "  ${YELLOW}Alt + arrows${NC}    Navigate panes"
echo -e "  ${YELLOW}Ctrl-a + n/p${NC}    Next/prev window"
echo -e "  ${YELLOW}Ctrl-a + 0-9${NC}    Jump to window"
echo -e "  ${YELLOW}Ctrl-a + d${NC}      Detach session"
echo ""
echo -e "${PINK}🚀 Enhanced terminal multiplexing made simple!${NC}"
echo ""
echo -e "Press any key to close..."
read -rsn1