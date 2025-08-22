#!/bin/bash
# Tmux Theme Switcher
# Apply theme colors to all tmux sessions

THEME="${1:-dracula}"

# Define colors for each theme
case "$THEME" in
    dracula)
        STATUS_BG="colour236"
        STATUS_FG="colour141"
        BORDER="colour238"
        ACTIVE_BORDER="colour141"
        ;;
    cyberpunk)
        STATUS_BG="colour235"
        STATUS_FG="colour198"
        BORDER="colour238"
        ACTIVE_BORDER="colour51"
        ;;
    nord)
        STATUS_BG="colour237"
        STATUS_FG="colour109"
        BORDER="colour238"
        ACTIVE_BORDER="colour109"
        ;;
    gruvbox)
        STATUS_BG="colour237"
        STATUS_FG="colour214"
        BORDER="colour238"
        ACTIVE_BORDER="colour175"
        ;;
    *)
        echo "Unknown theme: $THEME"
        exit 1
        ;;
esac

# Apply to all tmux sessions
if command -v tmux &>/dev/null && tmux list-sessions &>/dev/null 2>&1; then
    # Global options
    tmux set-option -g status-bg "$STATUS_BG" 2>/dev/null
    tmux set-option -g status-fg "$STATUS_FG" 2>/dev/null
    tmux set-option -g pane-border-style "fg=$BORDER" 2>/dev/null
    tmux set-option -g pane-active-border-style "fg=$ACTIVE_BORDER" 2>/dev/null
    
    # Window status colors
    tmux set-window-option -g window-status-current-style "fg=$STATUS_FG,bg=$STATUS_BG,bold" 2>/dev/null
    tmux set-window-option -g window-status-style "fg=$STATUS_FG,bg=$STATUS_BG" 2>/dev/null
    
    # Message colors
    tmux set-option -g message-style "fg=$STATUS_FG,bg=$STATUS_BG" 2>/dev/null
    tmux set-option -g message-command-style "fg=$STATUS_FG,bg=$STATUS_BG" 2>/dev/null
fi