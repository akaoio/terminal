#!/bin/bash
# AKAOIO Terminal Theme Engine
# Generate all theme configurations from JSON data files

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
THEME_DATA_DIR="$SCRIPT_DIR/theme/data"

# Function to get color from theme JSON
get_theme_color() {
    local theme="$1"
    local path="$2"
    local default="$3"
    
    if command -v jq &>/dev/null && [ -f "$THEME_DATA_DIR/${theme}.json" ]; then
        local result=$(jq -r "$path" "$THEME_DATA_DIR/${theme}.json" 2>/dev/null)
        if [ -n "$result" ] && [ "$result" != "null" ]; then
            echo "$result"
        else
            echo "$default"
        fi
    else
        echo "$default"
    fi
}

# Generate ZSH syntax highlighting colors
generate_zsh_syntax_colors() {
    local theme="${1:-dracula}"
    
    local fg_default=$(get_theme_color "$theme" '.colors.hex.white' '#f8f8f2')
    local fg_error=$(get_theme_color "$theme" '.colors.hex.red' '#ff5555')
    local fg_keyword=$(get_theme_color "$theme" '.colors.hex.pink' '#ff79c6')
    local fg_string=$(get_theme_color "$theme" '.colors.hex.yellow' '#f1fa8c')
    local fg_function=$(get_theme_color "$theme" '.colors.hex.green' '#50fa7b')
    local fg_command=$(get_theme_color "$theme" '.colors.hex.cyan' '#8be9fd')
    local fg_comment=$(get_theme_color "$theme" '.colors.hex.comment' '#6272a4')
    local fg_variable=$(get_theme_color "$theme" '.colors.hex.purple' '#bd93f9')
    local fg_constant=$(get_theme_color "$theme" '.colors.hex.orange' '#ffb86c')
    
    cat <<EOF
# ZSH Syntax Highlighting - $theme theme
typeset -A ZSH_HIGHLIGHT_STYLES
ZSH_HIGHLIGHT_STYLES[default]='fg=$fg_default'
ZSH_HIGHLIGHT_STYLES[unknown-token]='fg=$fg_error,bold'
ZSH_HIGHLIGHT_STYLES[reserved-word]='fg=$fg_keyword'
ZSH_HIGHLIGHT_STYLES[alias]='fg=$fg_function'
ZSH_HIGHLIGHT_STYLES[builtin]='fg=$fg_command'
ZSH_HIGHLIGHT_STYLES[function]='fg=$fg_function'
ZSH_HIGHLIGHT_STYLES[command]='fg=$fg_command'
ZSH_HIGHLIGHT_STYLES[precommand]='fg=$fg_function,underline'
ZSH_HIGHLIGHT_STYLES[commandseparator]='fg=$fg_keyword'
ZSH_HIGHLIGHT_STYLES[path]='fg=$fg_default,underline'
ZSH_HIGHLIGHT_STYLES[single-quoted-argument]='fg=$fg_string'
ZSH_HIGHLIGHT_STYLES[double-quoted-argument]='fg=$fg_string'
ZSH_HIGHLIGHT_STYLES[comment]='fg=$fg_comment'
EOF
}

# Generate LS_COLORS
generate_ls_colors() {
    local theme="${1:-dracula}"
    
    local dir=$(get_theme_color "$theme" '.colors.term.blue' '34')
    local link=$(get_theme_color "$theme" '.colors.term.cyan' '36')
    local exec=$(get_theme_color "$theme" '.colors.term.green' '32')
    local file=$(get_theme_color "$theme" '.colors.term.white' '37')
    
    echo "di=1;${dir}:ln=1;${link}:ex=1;${exec}:fi=0;${file}"
}

# Generate FZF colors
generate_fzf_colors() {
    local theme="${1:-dracula}"
    
    local bg=$(get_theme_color "$theme" '.colors.hex.background' '#282a36')
    local fg=$(get_theme_color "$theme" '.colors.hex.white' '#f8f8f2')
    local hl=$(get_theme_color "$theme" '.colors.hex.purple' '#bd93f9')
    local prompt=$(get_theme_color "$theme" '.colors.hex.green' '#50fa7b')
    local pointer=$(get_theme_color "$theme" '.colors.hex.pink' '#ff79c6')
    local marker=$(get_theme_color "$theme" '.colors.hex.pink' '#ff79c6')
    local spinner=$(get_theme_color "$theme" '.colors.hex.orange' '#ffb86c')
    local header=$(get_theme_color "$theme" '.colors.hex.comment' '#6272a4')
    
    echo "--color=fg:$fg,bg:$bg,hl:$hl,fg+:$fg,bg+:$bg,hl+:$hl,info:$spinner,prompt:$prompt,pointer:$pointer,marker:$marker,spinner:$spinner,header:$header"
}

# Generate tmux colors (returns color codes)
generate_tmux_colors() {
    local theme="${1:-dracula}"
    
    case "$theme" in
        dracula)
            echo "status_bg=colour236 status_fg=colour141 border=colour238 active_border=colour141"
            ;;
        cyberpunk)
            echo "status_bg=colour235 status_fg=colour198 border=colour238 active_border=colour51"
            ;;
        nord)
            echo "status_bg=colour237 status_fg=colour109 border=colour238 active_border=colour109"
            ;;
        gruvbox)
            echo "status_bg=colour237 status_fg=colour214 border=colour238 active_border=colour175"
            ;;
        *)
            echo "status_bg=colour235 status_fg=colour250 border=colour238 active_border=colour250"
            ;;
    esac
}

# Generate P10k colors
generate_p10k_colors() {
    local theme="${1:-dracula}"
    
    local context_fg=$(get_theme_color "$theme" '.colors.hex.purple' '#BD93F9')
    local dir_fg=$(get_theme_color "$theme" '.colors.hex.cyan' '#8BE9FD')
    local vcs_clean=$(get_theme_color "$theme" '.colors.hex.green' '#50FA7B')
    local vcs_modified=$(get_theme_color "$theme" '.colors.hex.yellow' '#F1FA8C')
    local vcs_untracked=$(get_theme_color "$theme" '.colors.hex.orange' '#FFB86C')
    local prompt_ok=$(get_theme_color "$theme" '.colors.hex.pink' '#FF79C6')
    local prompt_error=$(get_theme_color "$theme" '.colors.hex.red' '#FF5555')
    
    cat <<EOF
# P10k colors for $theme
typeset -g POWERLEVEL9K_CONTEXT_FOREGROUND='$context_fg'
typeset -g POWERLEVEL9K_DIR_FOREGROUND='$dir_fg'
typeset -g POWERLEVEL9K_VCS_CLEAN_FOREGROUND='$vcs_clean'
typeset -g POWERLEVEL9K_VCS_MODIFIED_FOREGROUND='$vcs_modified'
typeset -g POWERLEVEL9K_VCS_UNTRACKED_FOREGROUND='$vcs_untracked'
typeset -g POWERLEVEL9K_PROMPT_CHAR_OK_{VIINS,VICMD,VIVIS,VIOWR}_FOREGROUND='$prompt_ok'
typeset -g POWERLEVEL9K_PROMPT_CHAR_ERROR_{VIINS,VICMD,VIVIS,VIOWR}_FOREGROUND='$prompt_error'
EOF
}

# Main function - generate all configs for a theme
generate_theme_configs() {
    local theme="${1:-dracula}"
    
    echo "=== Generating configs for theme: $theme ==="
    echo ""
    
    echo "# ZSH Syntax Highlighting"
    generate_zsh_syntax_colors "$theme"
    echo ""
    
    echo "# LS_COLORS"
    echo "export LS_COLORS='$(generate_ls_colors "$theme")'"
    echo ""
    
    echo "# FZF Options"
    echo "export FZF_DEFAULT_OPTS=\"$(generate_fzf_colors "$theme")\""
    echo ""
    
    echo "# Tmux Colors"
    generate_tmux_colors "$theme"
    echo ""
    
    echo "# P10k Colors"
    generate_p10k_colors "$theme"
}

# If run directly, generate for specified theme
if [ "$#" -gt 0 ]; then
    generate_theme_configs "$1"
fi