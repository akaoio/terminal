#!/usr/bin/env bash
# DEX Footer Manager - Part of AKAOIO Terminal Suite

ACTION="${1:-toggle}"
FOOTER_FILE="/tmp/tmux-footer-${USER}"

# Check if footer is visible
is_footer_visible() {
    [ -f "$FOOTER_FILE" ] && tmux list-panes -t "$(tmux display -p '#S')" -F "#{pane_id}" | grep -q "$(cat $FOOTER_FILE)"
}

# Show footer
show_footer() {
    if ! is_footer_visible; then
        local current_session=$(tmux display -p '#S')
        local work_panes=$(tmux list-panes -t "$current_session" -F "#{pane_id}:#{pane_current_command}" | grep -v "dex-sidebar-content" | tail -1)
        local target_pane=$(echo "$work_panes" | cut -d: -f1)
        
        if [ -n "$target_pane" ]; then
            # Create footer pane at bottom
            FOOTER_ID=$(tmux split-window -v -t "$target_pane" -l 1 2>/dev/null)
            echo "$FOOTER_ID" > "$FOOTER_FILE"
            
            # Setup footer content with live updates
            tmux send-keys -t "$FOOTER_ID" "while true; do clear; echo -e '\\033[0;35m≡ DEX CONTROL \\033[0;36m│ \\033[1;33m[Ctrl+A+M] Menu \\033[0;36m│ \\033[1;32m[Ctrl+A+?] Help \\033[0;36m│ \\033[0;37m[Ctrl+A+D] Detach \\033[0;36m│ \\033[0;34m\$(date +\"%H:%M:%S\")'; sleep 1; done" C-m
            
            # Make footer non-selectable
            tmux set-option -t "$FOOTER_ID" -p remain-on-exit on
            tmux select-pane -t "$target_pane"
        fi
    fi
}

# Hide footer
hide_footer() {
    if is_footer_visible; then
        tmux kill-pane -t "$(cat $FOOTER_FILE)" 2>/dev/null
        rm -f "$FOOTER_FILE"
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