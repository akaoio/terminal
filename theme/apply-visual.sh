#!/bin/bash

# Apply theme changes that are actually VISIBLE in the terminal
# This changes the things users can SEE, not just variables

THEME_NAME="${1:-cyberpunk}"

# Apply theme-specific LS_COLORS that actually change file listing colors
case "$THEME_NAME" in
    dracula)
        # Dracula: Purple directories, pink executables, cyan links
        export LS_COLORS="di=1;35:ln=1;36:so=1;32:pi=33:ex=1;35:bd=34;46:cd=34;43:su=30;41:sg=30;46:tw=30;42:ow=30;43"
        export EXA_COLORS="di=1;35:ex=1;35:ln=1;36:*.md=1;33:*.json=1;34:*.js=1;32:*.ts=1;32:*.sh=1;31"
        ;;
    cyberpunk)
        # Cyberpunk: Bright neon colors - pink dirs, green exe, cyan links
        export LS_COLORS="di=1;95:ln=1;96:so=1;92:pi=1;93:ex=1;92:bd=1;91:cd=1;91:su=1;97;41:sg=1;97;44:tw=1;97;42:ow=1;97;43"
        export EXA_COLORS="di=1;95:ex=1;92:ln=1;96:*.md=1;93:*.json=1;94:*.js=1;92:*.ts=1;92:*.sh=1;91"
        ;;
    nord)
        # Nord: Cool blues and teals
        export LS_COLORS="di=1;34:ln=1;36:so=1;35:pi=33:ex=1;32:bd=34;46:cd=34;43:su=30;41:sg=30;46:tw=30;42:ow=30;43"
        export EXA_COLORS="di=1;34:ex=1;32:ln=1;36:*.md=1;33:*.json=1;34:*.js=1;32:*.ts=1;32:*.sh=1;31"
        ;;
    gruvbox)
        # Gruvbox: Warm earthy tones - yellow/orange
        export LS_COLORS="di=1;33:ln=1;36:so=1;35:pi=33:ex=1;32:bd=34;46:cd=34;43:su=30;41:sg=30;46:tw=30;42:ow=30;43"
        export EXA_COLORS="di=1;33:ex=1;32:ln=1;36:*.md=1;33:*.json=1;34:*.js=1;32:*.ts=1;32:*.sh=1;31"
        ;;
esac

# Update ZSH syntax highlighting colors (if zsh-syntax-highlighting is loaded)
if [ -n "$ZSH_VERSION" ] && [ -n "$ZSH_HIGHLIGHT_STYLES" ]; then
    case "$THEME_NAME" in
        dracula)
            ZSH_HIGHLIGHT_STYLES[default]='fg=248'
            ZSH_HIGHLIGHT_STYLES[command]='fg=141'          # Purple
            ZSH_HIGHLIGHT_STYLES[builtin]='fg=212'          # Pink
            ZSH_HIGHLIGHT_STYLES[function]='fg=84'          # Green
            ZSH_HIGHLIGHT_STYLES[alias]='fg=84'             # Green
            ZSH_HIGHLIGHT_STYLES[path]='fg=117'             # Cyan
            ZSH_HIGHLIGHT_STYLES[globbing]='fg=215'         # Orange
            ZSH_HIGHLIGHT_STYLES[single-quoted-argument]='fg=228'  # Yellow
            ZSH_HIGHLIGHT_STYLES[double-quoted-argument]='fg=228'  # Yellow
            ;;
        cyberpunk)
            ZSH_HIGHLIGHT_STYLES[default]='fg=15'           # Bright white
            ZSH_HIGHLIGHT_STYLES[command]='fg=198'          # Hot pink
            ZSH_HIGHLIGHT_STYLES[builtin]='fg=51'           # Cyan
            ZSH_HIGHLIGHT_STYLES[function]='fg=46'          # Neon green
            ZSH_HIGHLIGHT_STYLES[alias]='fg=226'            # Yellow
            ZSH_HIGHLIGHT_STYLES[path]='fg=51'              # Cyan
            ZSH_HIGHLIGHT_STYLES[globbing]='fg=208'         # Orange
            ZSH_HIGHLIGHT_STYLES[single-quoted-argument]='fg=226'  # Yellow
            ZSH_HIGHLIGHT_STYLES[double-quoted-argument]='fg=226'  # Yellow
            ;;
        nord)
            ZSH_HIGHLIGHT_STYLES[default]='fg=252'
            ZSH_HIGHLIGHT_STYLES[command]='fg=81'           # Blue
            ZSH_HIGHLIGHT_STYLES[builtin]='fg=139'          # Purple
            ZSH_HIGHLIGHT_STYLES[function]='fg=109'         # Cyan
            ZSH_HIGHLIGHT_STYLES[alias]='fg=109'            # Cyan
            ZSH_HIGHLIGHT_STYLES[path]='fg=116'             # Teal
            ZSH_HIGHLIGHT_STYLES[globbing]='fg=173'         # Orange
            ZSH_HIGHLIGHT_STYLES[single-quoted-argument]='fg=222'  # Yellow
            ZSH_HIGHLIGHT_STYLES[double-quoted-argument]='fg=222'  # Yellow
            ;;
        gruvbox)
            ZSH_HIGHLIGHT_STYLES[default]='fg=223'
            ZSH_HIGHLIGHT_STYLES[command]='fg=142'          # Green
            ZSH_HIGHLIGHT_STYLES[builtin]='fg=167'          # Red
            ZSH_HIGHLIGHT_STYLES[function]='fg=109'         # Blue
            ZSH_HIGHLIGHT_STYLES[alias]='fg=108'            # Green
            ZSH_HIGHLIGHT_STYLES[path]='fg=214'             # Yellow
            ZSH_HIGHLIGHT_STYLES[globbing]='fg=208'         # Orange
            ZSH_HIGHLIGHT_STYLES[single-quoted-argument]='fg=214'  # Yellow
            ZSH_HIGHLIGHT_STYLES[double-quoted-argument]='fg=214'  # Yellow
            ;;
    esac
    
    # Force syntax highlighting to refresh
    if typeset -f _zsh_highlight > /dev/null; then
        _zsh_highlight
    fi
fi

# Update prompt colors by modifying Powerlevel10k segments
# These environment variables affect p10k colors
case "$THEME_NAME" in
    dracula)
        export POWERLEVEL9K_DIR_FOREGROUND='141'        # Purple
        export POWERLEVEL9K_DIR_ANCHOR_FOREGROUND='212'  # Pink
        export POWERLEVEL9K_VCS_CLEAN_FOREGROUND='84'    # Green
        export POWERLEVEL9K_VCS_MODIFIED_FOREGROUND='228' # Yellow
        export POWERLEVEL9K_VCS_UNTRACKED_FOREGROUND='117' # Cyan
        export POWERLEVEL9K_STATUS_OK_FOREGROUND='84'     # Green
        export POWERLEVEL9K_STATUS_ERROR_FOREGROUND='203' # Red
        ;;
    cyberpunk)
        export POWERLEVEL9K_DIR_FOREGROUND='198'         # Hot Pink
        export POWERLEVEL9K_DIR_ANCHOR_FOREGROUND='51'    # Cyan
        export POWERLEVEL9K_VCS_CLEAN_FOREGROUND='46'     # Neon Green
        export POWERLEVEL9K_VCS_MODIFIED_FOREGROUND='226' # Yellow
        export POWERLEVEL9K_VCS_UNTRACKED_FOREGROUND='51' # Cyan
        export POWERLEVEL9K_STATUS_OK_FOREGROUND='46'     # Green
        export POWERLEVEL9K_STATUS_ERROR_FOREGROUND='196' # Red
        ;;
    nord)
        export POWERLEVEL9K_DIR_FOREGROUND='81'          # Blue
        export POWERLEVEL9K_DIR_ANCHOR_FOREGROUND='139'   # Purple
        export POWERLEVEL9K_VCS_CLEAN_FOREGROUND='109'    # Cyan
        export POWERLEVEL9K_VCS_MODIFIED_FOREGROUND='222' # Yellow
        export POWERLEVEL9K_VCS_UNTRACKED_FOREGROUND='116' # Teal
        export POWERLEVEL9K_STATUS_OK_FOREGROUND='109'    # Cyan
        export POWERLEVEL9K_STATUS_ERROR_FOREGROUND='131' # Red
        ;;
    gruvbox)
        export POWERLEVEL9K_DIR_FOREGROUND='214'         # Yellow
        export POWERLEVEL9K_DIR_ANCHOR_FOREGROUND='208'   # Orange
        export POWERLEVEL9K_VCS_CLEAN_FOREGROUND='142'    # Green
        export POWERLEVEL9K_VCS_MODIFIED_FOREGROUND='214' # Yellow
        export POWERLEVEL9K_VCS_UNTRACKED_FOREGROUND='109' # Blue
        export POWERLEVEL9K_STATUS_OK_FOREGROUND='142'    # Green
        export POWERLEVEL9K_STATUS_ERROR_FOREGROUND='167' # Red
        ;;
esac

# Update bat theme if available
if command -v bat > /dev/null 2>&1; then
    case "$THEME_NAME" in
        dracula) export BAT_THEME="Dracula" ;;
        cyberpunk) export BAT_THEME="TwoDark" ;;
        nord) export BAT_THEME="Nord" ;;
        gruvbox) export BAT_THEME="gruvbox-dark" ;;
    esac
fi

# Save the theme preference
echo "export TERMINAL_THEME='$THEME_NAME'" > ~/.terminal-theme

# Provide feedback
echo "Visual theme applied: $THEME_NAME"
echo "Changes visible in:"
echo "  • File listings (ls/exa colors)"
echo "  • Syntax highlighting (command colors)"
echo "  • Prompt colors (may need 'exec zsh' to fully apply)"
echo ""
echo "Note: Terminal background/foreground colors are set by your terminal emulator,"
echo "      not the shell. Check your terminal's preferences to change those."