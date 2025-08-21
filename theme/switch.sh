#!/bin/bash

# Theme switching helper that updates colors in current session
# This file gets sourced to update environment variables

THEME_NAME="${1:-cyberpunk}"
THEME_DIR="$(dirname "${BASH_SOURCE[0]}")"

# Get theme colors from Node.js CLI
if [ -f "$THEME_DIR/cli.js" ]; then
    # Set the theme first
    node "$THEME_DIR/cli.js" set "$THEME_NAME" > /dev/null 2>&1
    
    # Apply theme and evaluate the export commands
    eval "$(node "$THEME_DIR/cli.js" apply)"
    
    # Update LS_COLORS based on theme
    case "$THEME_NAME" in
        dracula)
            export LS_COLORS="di=1;36:ln=1;35:so=1;32:pi=33:ex=1;31:bd=34;46:cd=34;43:su=30;41:sg=30;46:tw=30;42:ow=30;43"
            ;;
        cyberpunk)
            export LS_COLORS="di=1;35:ln=1;36:so=1;32:pi=33:ex=1;35:bd=34;46:cd=34;43:su=30;41:sg=30;46:tw=30;42:ow=30;43"
            ;;
        nord)
            export LS_COLORS="di=1;34:ln=1;36:so=1;35:pi=33:ex=1;32:bd=34;46:cd=34;43:su=30;41:sg=30;46:tw=30;42:ow=30;43"
            ;;
        gruvbox)
            export LS_COLORS="di=1;33:ln=1;36:so=1;35:pi=33:ex=1;32:bd=34;46:cd=34;43:su=30;41:sg=30;46:tw=30;42:ow=30;43"
            ;;
    esac
    
    # Update ZSH syntax highlighting colors if available
    if [ -n "$ZSH_VERSION" ]; then
        case "$THEME_NAME" in
            dracula)
                ZSH_HIGHLIGHT_STYLES[default]='fg=248'
                ZSH_HIGHLIGHT_STYLES[command]='fg=141'
                ZSH_HIGHLIGHT_STYLES[builtin]='fg=212'
                ZSH_HIGHLIGHT_STYLES[function]='fg=84'
                ZSH_HIGHLIGHT_STYLES[alias]='fg=84'
                ;;
            cyberpunk)
                ZSH_HIGHLIGHT_STYLES[default]='fg=15'
                ZSH_HIGHLIGHT_STYLES[command]='fg=198'
                ZSH_HIGHLIGHT_STYLES[builtin]='fg=51'
                ZSH_HIGHLIGHT_STYLES[function]='fg=46'
                ZSH_HIGHLIGHT_STYLES[alias]='fg=226'
                ;;
            nord)
                ZSH_HIGHLIGHT_STYLES[default]='fg=252'
                ZSH_HIGHLIGHT_STYLES[command]='fg=81'
                ZSH_HIGHLIGHT_STYLES[builtin]='fg=139'
                ZSH_HIGHLIGHT_STYLES[function]='fg=109'
                ZSH_HIGHLIGHT_STYLES[alias]='fg=109'
                ;;
            gruvbox)
                ZSH_HIGHLIGHT_STYLES[default]='fg=223'
                ZSH_HIGHLIGHT_STYLES[command]='fg=142'
                ZSH_HIGHLIGHT_STYLES[builtin]='fg=167'
                ZSH_HIGHLIGHT_STYLES[function]='fg=109'
                ZSH_HIGHLIGHT_STYLES[alias]='fg=108'
                ;;
        esac
        
        # Apply highlighting changes if plugin is loaded
        if typeset -f _zsh_highlight > /dev/null; then
            _zsh_highlight
        fi
    fi
    
    # Update bat theme if available
    if command -v bat > /dev/null 2>&1; then
        case "$THEME_NAME" in
            dracula) export BAT_THEME="Dracula" ;;
            cyberpunk) export BAT_THEME="TwoDark" ;;
            nord) export BAT_THEME="Nord" ;;
            gruvbox) export BAT_THEME="gruvbox-dark" ;;
        esac
    fi
    
    # Save preference
    echo "export TERMINAL_THEME='$THEME_NAME'" > ~/.terminal-theme
    
    echo "Theme switched to: $THEME_NAME"
    echo "Colors updated in current session"
fi