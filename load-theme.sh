#!/bin/bash

# Load theme function for development/testing
# Usage: source load-theme.sh

theme() {
    local theme_cmd="${1:-list}"
    # First check if we're in the repo directory
    local theme_dir="$(pwd)/theme"
    
    # If not in repo, check home directory
    if [ ! -f "$theme_dir/cli.sh" ]; then
        theme_dir="$HOME/.config/terminal/theme"
    fi
    
    # If still not found, check if we're in Projects/terminal
    if [ ! -f "$theme_dir/cli.sh" ]; then
        theme_dir="$HOME/Projects/terminal/theme"
    fi
    
    if [ ! -f "$theme_dir/cli.sh" ]; then
        echo "Error: Theme system not found"
        echo "Searched in:"
        echo "  - $(pwd)/theme"
        echo "  - $HOME/.config/terminal/theme"
        echo "  - $HOME/Projects/terminal/theme"
        return 1
    fi
    
    case "$theme_cmd" in
        list)
            "$theme_dir/cli.sh" list
            ;;
        set)
            if [ -z "$2" ]; then
                echo "Usage: theme set <name>"
                return 1
            fi
            
            local THEME_NAME="$2"
            
            # Validate theme exists
            if [ ! -f "$theme_dir/data/${THEME_NAME}.json" ]; then
                echo "Error: Theme '$THEME_NAME' not found"
                echo "Available themes: dracula, cyberpunk, nord, gruvbox"
                return 1
            fi
            
            # Save preference
            "$theme_dir/cli.sh" set "$THEME_NAME" > /dev/null 2>&1
            export TERMINAL_THEME="$THEME_NAME"
            
            # Apply LS_COLORS immediately based on theme
            case "$THEME_NAME" in
                dracula)
                    export LS_COLORS="di=1;35:ln=1;36:so=1;32:pi=33:ex=1;35:bd=34;46:cd=34;43:su=30;41:sg=30;46:tw=30;42:ow=30;43"
                    export EXA_COLORS="di=1;35:ex=1;35:ln=1;36:*.md=1;33:*.json=1;34:*.js=1;32:*.ts=1;32:*.sh=1;31"
                    export BAT_THEME="Dracula"
                    ;;
                cyberpunk)
                    export LS_COLORS="di=1;95:ln=1;96:so=1;92:pi=1;93:ex=1;92:bd=1;91:cd=1;91:su=1;97;41:sg=1;97;44:tw=1;97;42:ow=1;97;43"
                    export EXA_COLORS="di=1;95:ex=1;92:ln=1;96:*.md=1;93:*.json=1;94:*.js=1;92:*.ts=1;92:*.sh=1;91"
                    export BAT_THEME="TwoDark"
                    ;;
                nord)
                    export LS_COLORS="di=1;34:ln=1;36:so=1;35:pi=33:ex=1;32:bd=34;46:cd=34;43:su=30;41:sg=30;46:tw=30;42:ow=30;43"
                    export EXA_COLORS="di=1;34:ex=1;32:ln=1;36:*.md=1;33:*.json=1;34:*.js=1;32:*.ts=1;32:*.sh=1;31"
                    export BAT_THEME="Nord"
                    ;;
                gruvbox)
                    export LS_COLORS="di=1;33:ln=1;36:so=1;35:pi=33:ex=1;32:bd=34;46:cd=34;43:su=30;41:sg=30;46:tw=30;42:ow=30;43"
                    export EXA_COLORS="di=1;33:ex=1;32:ln=1;36:*.md=1;33:*.json=1;34:*.js=1;32:*.ts=1;32:*.sh=1;31"
                    export BAT_THEME="gruvbox-dark"
                    ;;
            esac
            
            # Apply ZSH syntax highlighting colors if in ZSH
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
                
                # Force syntax highlighting refresh
                if typeset -f _zsh_highlight > /dev/null; then
                    _zsh_highlight
                fi
            fi
            
            echo "✓ Theme changed to: $THEME_NAME"
            echo "  • File colors updated (try 'ls -la')"
            echo "  • Syntax highlighting updated"
            echo "  • Changes applied immediately!"
            ;;
        get|current)
            "$theme_dir/cli.sh" get | grep '"name"' | cut -d'"' -f4
            ;;
        *)
            echo "Usage: theme [list|set <name>|get]"
            echo "Available themes: dracula, cyberpunk, nord, gruvbox"
            ;;
    esac
}

# Quick aliases
alias theme-dracula='theme set dracula'
alias theme-cyberpunk='theme set cyberpunk'
alias theme-nord='theme set nord'
alias theme-gruvbox='theme set gruvbox'

echo "✓ Theme command loaded!"
echo "Try: theme list"
echo "     theme set gruvbox"