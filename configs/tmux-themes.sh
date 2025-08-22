#!/bin/bash
# Tmux Theme Switcher
# Apply theme colors to all tmux sessions using theme engine

THEME="${1:-dracula}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
THEME_ENGINE="$SCRIPT_DIR/theme/theme-engine.sh"

# Source theme engine if available
if [ -f "$THEME_ENGINE" ]; then
    source "$THEME_ENGINE"
    
    # Get tmux colors from theme engine
    TMUX_COLORS=$(generate_tmux_colors "$THEME")
    
    # Parse the color values
    eval "$TMUX_COLORS"
    
    STATUS_BG="${status_bg:-colour235}"
    STATUS_FG="${status_fg:-colour250}"
    BORDER="${border:-colour238}"
    ACTIVE_BORDER="${active_border:-colour250}"
else
    # Fallback to defaults if theme engine not found
    echo "Warning: Theme engine not found, using defaults"
    STATUS_BG="colour235"
    STATUS_FG="colour250"
    BORDER="colour238"
    ACTIVE_BORDER="colour250"
fi

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