#!/usr/bin/env bash
# Tmux Theme Switcher
# Updates @bg/@fg/@accent/@comment/@highlight/@active user-variables in all
# running tmux sessions. Layout and format strings in tmux.conf are never
# touched — only colors change.

THEME="${1:-dracula}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
THEME_ENGINE="$SCRIPT_DIR/theme/theme-engine.sh"

if [ -f "$THEME_ENGINE" ]; then
    source "$THEME_ENGINE"
    eval "$(generate_tmux_colors "$THEME")"
    BG="${tmux_bg:-#282a36}"
    FG="${tmux_fg:-#f8f8f2}"
    ACCENT="${tmux_accent:-#8be9fd}"
    COMMENT="${tmux_comment:-#6272a4}"
    HIGHLIGHT="${tmux_highlight:-#bd93f9}"
    ACTIVE="${tmux_active:-#ff79c6}"
else
    echo "Warning: Theme engine not found, using dracula defaults"
    BG="#282a36"; FG="#f8f8f2"; ACCENT="#8be9fd"
    COMMENT="#6272a4"; HIGHLIGHT="#bd93f9"; ACTIVE="#ff79c6"
fi

if command -v tmux &>/dev/null && tmux list-sessions &>/dev/null 2>&1; then
    tmux set-option -g @bg        "$BG"        2>/dev/null
    tmux set-option -g @fg        "$FG"        2>/dev/null
    tmux set-option -g @accent    "$ACCENT"    2>/dev/null
    tmux set-option -g @comment   "$COMMENT"   2>/dev/null
    tmux set-option -g @highlight "$HIGHLIGHT" 2>/dev/null
    tmux set-option -g @active    "$ACTIVE"    2>/dev/null
    tmux refresh-client -S 2>/dev/null
    echo "tmux theme updated: $THEME"
else
    echo "No active tmux sessions — colors will apply on next tmux start"
fi