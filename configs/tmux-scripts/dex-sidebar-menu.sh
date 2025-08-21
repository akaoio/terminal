#!/usr/bin/env bash
# DEX Sidebar Menu - Using tmux native display-menu

ACTION="${1:-toggle}"
SIDEBAR_FILE="/tmp/tmux-sidebar-menu-${USER}"

# Create native tmux menu
show_sidebar_menu() {
    # Get current session data
    local sessions=$(tmux list-sessions -F "#{session_name}" 2>/dev/null | head -5)
    local windows=$(tmux list-windows -F "#{window_index}:#{window_name}" 2>/dev/null | head -5)
    
    # Build dynamic menu
    local menu_items=""
    
    # Sessions section
    menu_items+="'Sessions' '' ''"
    menu_items+="'────────' '' ''"
    while IFS= read -r session; do
        if [ -n "$session" ]; then
            menu_items+="'→ $session' 'switch-client -t $session' ''"
        fi
    done <<< "$sessions"
    
    # Add separator
    menu_items+="'' '' ''"
    
    # Windows section  
    menu_items+="'Windows' '' ''"
    menu_items+="'───────' '' ''"
    while IFS= read -r window; do
        if [ -n "$window" ]; then
            local idx="${window%:*}"
            local name="${window#*:}"
            menu_items+="'→ $idx: $name' 'select-window -t $idx' ''"
        fi
    done <<< "$windows"
    
    # Add separator
    menu_items+="'' '' ''"
    
    # Actions section
    menu_items+="'Actions' '' ''"
    menu_items+="'───────' '' ''"
    menu_items+="'+ New Session' 'command-prompt -p \"Session name:\" \"new-session -d -s %%\"' ''"
    menu_items+="'+ New Window' 'new-window' ''"
    menu_items+="'+ Split →' 'split-window -h' ''"
    menu_items+="'+ Split ↓' 'split-window -v' ''"
    menu_items+="'✎ Rename' 'command-prompt -p \"New name:\" \"rename-window %%\"' ''"
    menu_items+="'× Kill' 'confirm-before -p \"Kill current window? (y/n)\" kill-window' ''"
    
    # Show the menu
    eval "tmux display-menu -T 'DEX Control Panel' $menu_items"
}

# Visual sidebar pane with live info
show_visual_sidebar() {
    local current_session=$(tmux display -p '#S')
    local work_panes=$(tmux list-panes -t "$current_session" -F "#{pane_id}:#{pane_current_command}" | grep -v "DEX CONTROL\|dex-sidebar" | head -1)
    local target_pane=$(echo "$work_panes" | cut -d: -f1)
    
    if [ -n "$target_pane" ]; then
        # Create visual sidebar pane
        local sidebar_id=$(tmux split-window -h -b -l 30 -t "$target_pane" -P)
        echo "$sidebar_id" > "$SIDEBAR_FILE"
        
        # Send live info display command
        tmux send-keys -t "$sidebar_id" "bash -c '
while true; do
    clear
    echo -e \"\\033[1;36m╔═══════════════════════════════╗\\033[0m\"
    echo -e \"\\033[1;36m║        DEX LIVE INFO          ║\\033[0m\"
    echo -e \"\\033[1;36m╚═══════════════════════════════╝\\033[0m\"
    echo \"\"
    
    echo -e \"\\033[1;32mSESSIONS:\\033[0m\"
    tmux list-sessions -F \"#{?session_attached,● ,○ }#{session_name}\" 2>/dev/null | head -5
    echo \"\"
    
    echo -e \"\\033[1;33mWINDOWS:\\033[0m\"
    tmux list-windows -F \"#{?window_active,● ,  }#{window_index}: #{window_name}\" 2>/dev/null | head -5
    echo \"\"
    
    echo -e \"\\033[1;35mPANES:\\033[0m\"
    echo \"  Total: \\$(tmux list-panes | wc -l) panes\"
    tmux list-panes -F \"#{?pane_active,● ,  }Pane #{pane_index}\" 2>/dev/null
    echo \"\"
    
    echo -e \"\\033[1;31mCONTROLS:\\033[0m\"
    echo -e \"  \\033[1;33mCtrl+A + M\\033[0m - Menu\"
    echo -e \"  \\033[1;33mCtrl+A + ?\\033[0m - Help\"
    echo -e \"  \\033[1;33mCtrl+A + F\\033[0m - Footer\"
    echo \"\"
    echo -e \"\\033[0;36m$(date +\"%H:%M:%S\")\\033[0m\"
    
    sleep 2
done
'" C-m
        
        # Return focus to work pane
        tmux select-pane -t "$target_pane"
    fi
}

# Hide visual sidebar
hide_visual_sidebar() {
    if [ -f "$SIDEBAR_FILE" ]; then
        local sidebar_id=$(cat "$SIDEBAR_FILE")
        if tmux list-panes -a -F "#{pane_id}" | grep -q "$sidebar_id"; then
            tmux kill-pane -t "$sidebar_id" 2>/dev/null
        fi
        rm -f "$SIDEBAR_FILE"
    fi
}

# Check if visual sidebar is visible
is_visual_sidebar_visible() {
    [ -f "$SIDEBAR_FILE" ] && tmux list-panes -a -F "#{pane_id}" | grep -q "$(cat $SIDEBAR_FILE)"
}

case "$ACTION" in
    menu)
        show_sidebar_menu
        ;;
    show)
        hide_visual_sidebar  # Hide any existing first
        show_visual_sidebar
        ;;
    hide)
        hide_visual_sidebar
        ;;
    toggle)
        if is_visual_sidebar_visible; then
            hide_visual_sidebar
        else
            show_visual_sidebar
        fi
        ;;
    *)
        # Default: show menu + visual sidebar
        if is_visual_sidebar_visible; then
            hide_visual_sidebar
            show_sidebar_menu
        else
            show_visual_sidebar
            show_sidebar_menu
        fi
        ;;
esac