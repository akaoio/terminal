#!/usr/bin/env bash
# DEX Sidebar Content - Interactive Control Panel

# Colors
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
PURPLE='\033[0;35m'
RED='\033[0;31m'
NC='\033[0m'
BOLD='\033[1m'
DIM='\033[2m'

# Clear screen
clear

# Draw sidebar UI
draw_sidebar() {
    local selected="${1:-1}"
    
    # Header
    echo -e "${BOLD}${CYAN}╔════════════════════════════╗${NC}"
    echo -e "${BOLD}${CYAN}║      DEX CONTROL PANEL     ║${NC}"
    echo -e "${BOLD}${CYAN}╠════════════════════════════╣${NC}"
    
    # Sessions section
    echo -e "${BOLD}${GREEN}║ SESSIONS                   ║${NC}"
    echo -e "${CYAN}╟────────────────────────────╢${NC}"
    
    local sessions=$(tmux list-sessions -F "#{session_name}:#{?session_attached,*,}" 2>/dev/null || echo "")
    if [ -n "$sessions" ]; then
        while IFS= read -r session; do
            local name="${session%:*}"
            local attached="${session#*:}"
            if [ "$attached" = "*" ]; then
                echo -e "║ ${GREEN}● $name (current)${NC}"
            else
                echo -e "║   ○ $name"
            fi
        done <<< "$sessions"
    else
        echo -e "║   No other sessions"
    fi
    
    # Windows section
    echo -e "${CYAN}╟────────────────────────────╢${NC}"
    echo -e "${BOLD}${YELLOW}║ WINDOWS                    ║${NC}"
    echo -e "${CYAN}╟────────────────────────────╢${NC}"
    
    local windows=$(tmux list-windows -F "#{window_index}:#{window_name}:#{?window_active,*,}" 2>/dev/null)
    if [ -n "$windows" ]; then
        while IFS= read -r window; do
            local idx="${window%%:*}"
            local rest="${window#*:}"
            local name="${rest%:*}"
            local active="${rest#*:}"
            if [ "$active" = "*" ]; then
                echo -e "║ ${YELLOW}● $idx: $name (active)${NC}"
            else
                echo -e "║   $idx: $name"
            fi
        done <<< "$windows"
    fi
    
    # Panes section
    echo -e "${CYAN}╟────────────────────────────╢${NC}"
    echo -e "${BOLD}${PURPLE}║ PANES                      ║${NC}"
    echo -e "${CYAN}╟────────────────────────────╢${NC}"
    
    local panes=$(tmux list-panes -F "#{pane_index}:#{?pane_active,active,}" 2>/dev/null)
    local pane_count=$(echo "$panes" | wc -l)
    echo -e "║   Total: $pane_count panes"
    if [ -n "$panes" ]; then
        while IFS= read -r pane; do
            local idx="${pane%:*}"
            local active="${pane#*:}"
            if [ "$active" = "active" ]; then
                echo -e "║ ${PURPLE}● Pane $idx (active)${NC}"
            else
                echo -e "║   ○ Pane $idx"
            fi
        done <<< "$panes"
    fi
    
    # Actions section
    echo -e "${CYAN}╟────────────────────────────╢${NC}"
    echo -e "${BOLD}${RED}║ ACTIONS                    ║${NC}"
    echo -e "${CYAN}╟────────────────────────────╢${NC}"
    echo -e "║ ${BOLD}[n]${NC} New session"
    echo -e "║ ${BOLD}[w]${NC} New window"
    echo -e "║ ${BOLD}[p]${NC} Split horizontal"
    echo -e "║ ${BOLD}[v]${NC} Split vertical"
    echo -e "║ ${BOLD}[r]${NC} Rename current"
    echo -e "║ ${BOLD}[k]${NC} Kill current"
    echo -e "║ ${BOLD}[s]${NC} Switch session"
    echo -e "║ ${BOLD}[1-9]${NC} Jump to window"
    echo -e "║ ${BOLD}[h/?]${NC} Help"
    echo -e "║ ${BOLD}[q]${NC} Close sidebar"
    echo -e "${CYAN}╚════════════════════════════╝${NC}"
    
    # Status line
    echo ""
    echo -e "${GREEN}Press a key to perform action${NC}"
}

# Interactive loop with proper input handling
interactive_loop() {
    while true; do
        clear
        draw_sidebar
        
        echo ""
        echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -e "${DIM}DEX Enhanced UI - Ready for input...${NC}"
        
        # Better input handling for tmux pane
        if [ -t 0 ]; then
            # Direct terminal input
            read -rsn1 key
        else
            # Fallback for tmux pane
            exec < /dev/tty
            read -rsn1 key
        fi
        
        case "$key" in
            n|N) # New session
                echo ""
                echo -e "${YELLOW}Enter session name: ${NC}"
                exec < /dev/tty
                read session_name
                if [ -n "$session_name" ]; then
                    tmux new-session -d -s "$session_name" 2>/dev/null
                    echo -e "${GREEN}✓ Created session: $session_name${NC}"
                else
                    echo -e "${RED}✗ No name provided${NC}"
                fi
                sleep 2
                ;;
            w|W) # New window
                tmux new-window 2>/dev/null
                echo -e "${GREEN}✓ Created new window${NC}"
                sleep 1
                ;;
            p|P) # Split pane
                tmux split-window -h 2>/dev/null
                echo -e "${GREEN}✓ Split pane horizontally${NC}"
                sleep 1
                ;;
            v|V) # Split vertical
                tmux split-window -v 2>/dev/null
                echo -e "${GREEN}✓ Split pane vertically${NC}"
                sleep 1
                ;;
            r|R) # Rename
                echo ""
                echo -e "${YELLOW}Enter new name: ${NC}"
                exec < /dev/tty
                read new_name
                if [ -n "$new_name" ]; then
                    tmux rename-window "$new_name" 2>/dev/null
                    echo -e "${GREEN}✓ Renamed to: $new_name${NC}"
                else
                    echo -e "${RED}✗ No name provided${NC}"
                fi
                sleep 2
                ;;
            k|K) # Kill current
                echo ""
                echo -e "${RED}Kill current window? (y/n): ${NC}"
                if [ -t 0 ]; then
                    read -rsn1 confirm
                else
                    exec < /dev/tty
                    read -rsn1 confirm
                fi
                if [ "$confirm" = "y" ] || [ "$confirm" = "Y" ]; then
                    tmux kill-window 2>/dev/null
                    echo -e "${GREEN}✓ Window killed${NC}"
                    sleep 1
                    break
                else
                    echo -e "${YELLOW}Cancelled${NC}"
                    sleep 1
                fi
                ;;
            s|S) # Switch session
                tmux choose-session 2>/dev/null
                break
                ;;
            [1-9]) # Jump to window
                tmux select-window -t "$key" 2>/dev/null
                echo -e "${GREEN}✓ Switched to window $key${NC}"
                sleep 1
                ;;
            h|H|\?) # Help
                clear
                echo -e "${CYAN}╔══════════════════════════════╗${NC}"
                echo -e "${CYAN}║       DEX SIDEBAR HELP       ║${NC}"
                echo -e "${CYAN}╚══════════════════════════════╝${NC}"
                echo ""
                echo -e "${YELLOW}ACTIONS:${NC}"
                echo -e "  n - New session"
                echo -e "  w - New window" 
                echo -e "  p - Split horizontal"
                echo -e "  v - Split vertical"
                echo -e "  r - Rename current"
                echo -e "  k - Kill current"
                echo -e "  s - Switch session"
                echo -e "  1-9 - Jump to window"
                echo -e "  h/? - This help"
                echo -e "  q - Close sidebar"
                echo ""
                echo -e "${DIM}Press any key to continue...${NC}"
                if [ -t 0 ]; then
                    read -rsn1
                else
                    exec < /dev/tty
                    read -rsn1
                fi
                ;;
            q|Q|$'\x1b') # Quit (q, Q, or Escape)
                echo -e "\n${CYAN}Closing sidebar...${NC}"
                sleep 1
                # Kill this pane
                tmux kill-pane -t "$(tmux display -p '#{pane_id}')" 2>/dev/null
                exit 0
                ;;
            *) # Unknown key
                echo ""
                echo -e "${RED}Unknown key: '$key'${NC}"
                echo -e "${YELLOW}Press 'h' for help or 'q' to quit${NC}"
                sleep 2
                ;;
        esac
    done
}

# Start interactive loop
interactive_loop