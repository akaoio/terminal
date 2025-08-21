#!/usr/bin/env bash
# DEX Footer Manager - Enhanced footer with proper tmux integration

ACTION="${1:-toggle}"
FOOTER_FILE="/tmp/tmux-footer-${USER}"
FOOTER_HEIGHT=2

# Check if footer is visible
is_footer_visible() {
    if [ -f "$FOOTER_FILE" ]; then
        local footer_id=$(cat "$FOOTER_FILE")
        tmux list-panes -t "$(tmux display -p '#S')" -F "#{pane_id}" 2>/dev/null | grep -q "$footer_id"
    else
        return 1
    fi
}

# Show footer with enhanced display
show_footer() {
    if ! is_footer_visible; then
        local current_session=$(tmux display -p '#S')
        
        # Find the main content area (avoid special panes)
        local main_panes=$(tmux list-panes -t "$current_session" -F "#{pane_id}:#{pane_current_command}:#{pane_width}" 2>/dev/null | grep -v -E "DEX CONTROL" | sort -t: -k3 -nr | head -1)
        local target_pane=$(echo "$main_panes" | cut -d: -f1)
        
        if [ -n "$target_pane" ]; then
            # Create footer pane at bottom with proper height
            FOOTER_ID=$(tmux split-window -v -t "$target_pane" -l $FOOTER_HEIGHT -c "#{pane_current_path}" 2>/dev/null)
            
            if [ $? -eq 0 ] && [ -n "$FOOTER_ID" ]; then
                echo "$FOOTER_ID" > "$FOOTER_FILE"
                
                # Create enhanced footer script and run it
                cat > "/tmp/dex-footer-content-${USER}.sh" << 'FOOTEREOF'
#!/bin/bash
# Footer content with live updates

get_session_info() {
    local session_name=$(tmux display -p '#S' 2>/dev/null)
    local window_count=$(tmux list-windows 2>/dev/null | wc -l)
    local pane_count=$(tmux list-panes 2>/dev/null | wc -l)
    echo "$session_name │ $window_count windows │ $pane_count panes"
}

get_status_info() {
    local prefix_status=""
    if tmux display -p '#{?client_prefix,PREFIX,}' 2>/dev/null | grep -q "PREFIX"; then
        prefix_status=" \033[7;38;5;203m PREFIX \033[0;38;5;117m"
    fi
    echo "$prefix_status"
}

# Main footer loop
while true; do
    clear
    
    # Top line - controls
    echo -e "\033[38;5;117m┌─ \033[38;5;141mDEX CONTROL\033[38;5;117m ──────────────────────────────────────────────────┐\033[0m"
    
    # Bottom line - status and info
    local session_info=$(get_session_info)
    local status_info=$(get_status_info)
    local current_time=$(date +'%H:%M:%S')
    
    printf "\033[38;5;117m│\033[38;5;84m[Ctrl+A+?]\033[38;5;253m Help \033[38;5;212m[Ctrl+A+D]\033[38;5;253m Detach \033[38;5;141m[Ctrl+A+F]\033[38;5;253m Footer%s\033[38;5;117m│ \033[38;5;253m%s\033[38;5;117m │ \033[38;5;117m%s\033[38;5;117m │\033[0m\n" "$status_info" "$session_info" "$current_time"
    
    sleep 1
done
FOOTEREOF
                
                chmod +x "/tmp/dex-footer-content-${USER}.sh"
                
                # Start footer content
                tmux send-keys -t "$FOOTER_ID" "bash /tmp/dex-footer-content-${USER}.sh" C-m
                
                # Configure footer pane properties
                tmux set-option -t "$FOOTER_ID" -p remain-on-exit on
                tmux set-option -t "$FOOTER_ID" -p allow-rename off
                
                # Return focus to main pane
                tmux select-pane -t "$target_pane"
                
                echo "Footer created successfully with ID: $FOOTER_ID" >> "/tmp/dex-debug.log"
            else
                echo "Failed to create footer pane" >> "/tmp/dex-debug.log"
            fi
        else
            echo "No suitable target pane found for footer" >> "/tmp/dex-debug.log"
        fi
    fi
}

# Hide footer
hide_footer() {
    if is_footer_visible; then
        local footer_id=$(cat "$FOOTER_FILE")
        tmux kill-pane -t "$footer_id" 2>/dev/null
        rm -f "$FOOTER_FILE"
        rm -f "/tmp/dex-footer-content-${USER}.sh"
        echo "Footer removed: $footer_id" >> "/tmp/dex-debug.log"
    fi
}

# Toggle footer
case "$ACTION" in
    show)   show_footer ;;
    hide)   hide_footer ;;
    toggle) 
        if is_footer_visible; then
            hide_footer
        else
            show_footer
        fi
        ;;
esac