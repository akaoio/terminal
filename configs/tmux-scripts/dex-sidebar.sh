#!/usr/bin/env bash
# DEX Sidebar Manager - Part of AKAOIO Terminal Suite

ACTION="${1:-toggle}"
SIDEBAR_WIDTH=30
SIDEBAR_FILE="/tmp/tmux-sidebar-${USER}"

# Check if sidebar is visible
is_sidebar_visible() {
    [ -f "$SIDEBAR_FILE" ] && tmux list-panes -t "$(tmux display -p '#S')" -F "#{pane_id}" | grep -q "$(cat $SIDEBAR_FILE)"
}

# Show sidebar
show_sidebar() {
    if ! is_sidebar_visible; then
        # Find a work pane (not footer pane)
        local current_session=$(tmux display -p '#S')
        local work_panes=$(tmux list-panes -t "$current_session" -F "#{pane_id}:#{pane_current_command}" | grep -v "bash.*while.*DEX CONTROL" | head -1)
        local target_pane=$(echo "$work_panes" | cut -d: -f1)
        
        if [ -n "$target_pane" ]; then
            # Create sidebar pane on the left of work area
            SIDEBAR_ID=$(tmux split-window -h -b -l $SIDEBAR_WIDTH -t "$target_pane" "bash ~/.tmux/dex-sidebar-content.sh" 2>/dev/null)
            echo "$SIDEBAR_ID" > "$SIDEBAR_FILE"
            tmux select-pane -t "$target_pane" 2>/dev/null
        fi
    fi
}

# Hide sidebar
hide_sidebar() {
    if is_sidebar_visible; then
        tmux kill-pane -t "$(cat $SIDEBAR_FILE)" 2>/dev/null
        rm -f "$SIDEBAR_FILE"
    fi
}

# Toggle sidebar
case "$ACTION" in
    show)   show_sidebar ;;
    hide)   hide_sidebar ;;
    toggle) 
        if is_sidebar_visible; then
            hide_sidebar
        else
            show_sidebar
        fi
        ;;
esac