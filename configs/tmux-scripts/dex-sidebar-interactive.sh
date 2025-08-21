#!/usr/bin/env bash
# DEX Interactive Sidebar - Real tmux integration

SIDEBAR_WIDTH=30
SIDEBAR_FILE="/tmp/tmux-sidebar-${USER}"
SIDEBAR_COMMANDS="/tmp/tmux-sidebar-commands-${USER}"

# Create interactive sidebar with real tmux integration
create_interactive_sidebar() {
    local current_session=$(tmux display -p '#S')
    local work_panes=$(tmux list-panes -t "$current_session" -F "#{pane_id}:#{pane_current_command}" | grep -v "DEX CONTROL" | head -1)
    local target_pane=$(echo "$work_panes" | cut -d: -f1)
    
    if [ -n "$target_pane" ]; then
        # Create sidebar pane
        SIDEBAR_ID=$(tmux split-window -h -b -l $SIDEBAR_WIDTH -t "$target_pane" -P)
        echo "$SIDEBAR_ID" > "$SIDEBAR_FILE"
        
        # Setup sidebar with tmux command mode
        tmux send-keys -t "$SIDEBAR_ID" "bash -c 'source $0 && run_sidebar_ui'" C-m
        
        # Return focus to original pane
        tmux select-pane -t "$target_pane"
    fi
}

# Main sidebar UI function
run_sidebar_ui() {
    clear
    echo -e "\033[1;36m╔════════════════════════════════╗\033[0m"
    echo -e "\033[1;36m║        DEX CONTROL PANEL       ║\033[0m"
    echo -e "\033[1;36m╚════════════════════════════════╝\033[0m"
    echo ""
    
    # Live data display
    show_live_data() {
        echo -e "\033[1;32mSESSIONS:\033[0m"
        local sessions=$(tmux list-sessions -F "#{session_name}:#{?session_attached,*,}" 2>/dev/null)
        if [ -n "$sessions" ]; then
            while IFS= read -r session; do
                local name="${session%:*}"
                local attached="${session#*:}"
                if [ "$attached" = "*" ]; then
                    echo -e "  \033[0;32m● $name (current)\033[0m"
                else
                    echo -e "  ○ $name"
                fi
            done <<< "$sessions"
        fi
        
        echo ""
        echo -e "\033[1;33mWINDOWS:\033[0m"
        local windows=$(tmux list-windows -F "#{window_index}:#{window_name}:#{?window_active,*,}" 2>/dev/null)
        if [ -n "$windows" ]; then
            while IFS= read -r window; do
                local idx="${window%%:*}"
                local rest="${window#*:}"
                local name="${rest%:*}"
                local active="${rest#*:}"
                if [ "$active" = "*" ]; then
                    echo -e "  \033[1;33m● $idx: $name (active)\033[0m"
                else
                    echo -e "  $idx: $name"
                fi
            done <<< "$windows"
        fi
        
        echo ""
        echo -e "\033[1;35mPANES:\033[0m"
        local panes=$(tmux list-panes -F "#{pane_index}:#{?pane_active,active,}" 2>/dev/null)
        local pane_count=$(echo "$panes" | wc -l)
        echo -e "  Total: $pane_count panes"
        
        echo ""
        echo -e "\033[1;31mACTIONS:\033[0m"
        echo -e "  \033[1;33m[1] New session\033[0m"
        echo -e "  \033[1;33m[2] New window\033[0m"
        echo -e "  \033[1;33m[3] Split horizontal\033[0m"
        echo -e "  \033[1;33m[4] Split vertical\033[0m"
        echo -e "  \033[1;33m[5] Switch session\033[0m"
        echo -e "  \033[1;33m[q] Close sidebar\033[0m"
        echo ""
        echo -e "\033[0;36mEnter number or 'q' to quit:\033[0m"
    }
    
    # Main interactive loop
    while true; do
        clear
        show_live_data
        
        read -n 1 choice
        case "$choice" in
            1)
                echo ""
                echo -e "\033[1;33mEnter session name: \033[0m"
                read session_name
                if [ -n "$session_name" ]; then
                    tmux new-session -d -s "$session_name" 2>/dev/null
                    echo -e "\033[1;32m✓ Created session: $session_name\033[0m"
                    sleep 2
                fi
                ;;
            2)
                tmux new-window 2>/dev/null
                echo -e "\033[1;32m✓ Created new window\033[0m"
                sleep 1
                ;;
            3)
                tmux split-window -h 2>/dev/null
                echo -e "\033[1;32m✓ Split horizontally\033[0m"
                sleep 1
                ;;
            4)
                tmux split-window -v 2>/dev/null
                echo -e "\033[1;32m✓ Split vertically\033[0m"
                sleep 1
                ;;
            5)
                tmux choose-session 2>/dev/null
                ;;
            q|Q)
                echo -e "\033[1;36m\nClosing sidebar...\033[0m"
                sleep 1
                tmux kill-pane -t "$(tmux display -p '#{pane_id}')" 2>/dev/null
                exit 0
                ;;
            *)
                echo -e "\033[1;31mInvalid choice. Try again...\033[0m"
                sleep 1
                ;;
        esac
    done
}

# Check what action to perform
ACTION="${1:-toggle}"
case "$ACTION" in
    show)
        create_interactive_sidebar
        ;;
    hide)
        if [ -f "$SIDEBAR_FILE" ]; then
            tmux kill-pane -t "$(cat $SIDEBAR_FILE)" 2>/dev/null
            rm -f "$SIDEBAR_FILE"
        fi
        ;;
    toggle)
        if [ -f "$SIDEBAR_FILE" ] && tmux list-panes -t "$(tmux display -p '#S')" -F "#{pane_id}" | grep -q "$(cat $SIDEBAR_FILE)"; then
            # Hide
            tmux kill-pane -t "$(cat $SIDEBAR_FILE)" 2>/dev/null
            rm -f "$SIDEBAR_FILE"
        else
            # Show
            create_interactive_sidebar
        fi
        ;;
esac