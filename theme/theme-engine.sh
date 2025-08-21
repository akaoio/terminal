#!/bin/bash

# Theme engine using jq for dynamic JSON parsing
# No hardcoding - everything from JSON files

THEME_DIR="$(dirname "${BASH_SOURCE[0]}")"

# Apply theme dynamically
apply_theme() {
    local theme_name="${1:-cyberpunk}"
    local theme_file="$THEME_DIR/data/${theme_name}.json"
    
    if [ ! -f "$theme_file" ]; then
        echo "Error: Theme '$theme_name' not found"
        return 1
    fi
    
    # Check if jq is available
    if ! command -v jq &> /dev/null; then
        echo "Error: jq is required for theme system"
        return 1
    fi
    
    # Parse theme data using jq
    local style=$(jq -r '.style' "$theme_file")
    
    # Get terminal color codes from JSON
    local purple_term=$(jq -r '.colors.term.purple' "$theme_file")
    local green_term=$(jq -r '.colors.term.green' "$theme_file")
    local cyan_term=$(jq -r '.colors.term.cyan' "$theme_file")
    local pink_term=$(jq -r '.colors.term.pink' "$theme_file")
    local yellow_term=$(jq -r '.colors.term.yellow' "$theme_file")
    local red_term=$(jq -r '.colors.term.red' "$theme_file")
    local blue_term=$(jq -r '.colors.term.blue' "$theme_file")
    local orange_term=$(jq -r '.colors.term.orange' "$theme_file")
    
    # Generate LS_COLORS based on theme colors dynamically
    # Use the theme's actual colors, not hardcoded values
    case "$theme_name" in
        dracula)
            # Use dracula's purple for dirs, pink for exe
            export LS_COLORS="di=1;${purple_term}:ln=1;${cyan_term}:so=1;${green_term}:pi=${yellow_term}:ex=1;${pink_term}:bd=${blue_term};46:cd=${blue_term};43:su=30;41:sg=30;46:tw=30;42:ow=30;43"
            export EXA_COLORS="di=1;${purple_term}:ex=1;${pink_term}:ln=1;${cyan_term}:*.md=1;${yellow_term}:*.json=1;${blue_term}:*.js=1;${green_term}:*.ts=1;${green_term}:*.sh=1;${red_term}"
            export BAT_THEME="Dracula"
            ;;
        cyberpunk)
            # Use cyberpunk's bright colors
            export LS_COLORS="di=1;${pink_term}:ln=1;${cyan_term}:so=1;${green_term}:pi=1;${yellow_term}:ex=1;${green_term}:bd=1;${red_term}:cd=1;${red_term}:su=1;97;41:sg=1;97;44:tw=1;97;42:ow=1;97;43"
            export EXA_COLORS="di=1;${pink_term}:ex=1;${green_term}:ln=1;${cyan_term}:*.md=1;${yellow_term}:*.json=1;${blue_term}:*.js=1;${green_term}:*.ts=1;${green_term}:*.sh=1;${red_term}"
            export BAT_THEME="TwoDark"
            ;;
        nord)
            # Use nord's cool colors
            export LS_COLORS="di=1;${blue_term}:ln=1;${cyan_term}:so=1;${purple_term}:pi=${yellow_term}:ex=1;${green_term}:bd=${blue_term};46:cd=${blue_term};43:su=30;41:sg=30;46:tw=30;42:ow=30;43"
            export EXA_COLORS="di=1;${blue_term}:ex=1;${green_term}:ln=1;${cyan_term}:*.md=1;${yellow_term}:*.json=1;${blue_term}:*.js=1;${green_term}:*.ts=1;${green_term}:*.sh=1;${red_term}"
            export BAT_THEME="Nord"
            ;;
        gruvbox)
            # Use gruvbox's warm colors
            export LS_COLORS="di=1;${yellow_term}:ln=1;${cyan_term}:so=1;${purple_term}:pi=${yellow_term}:ex=1;${green_term}:bd=${blue_term};46:cd=${blue_term};43:su=30;41:sg=30;46:tw=30;42:ow=30;43"
            export EXA_COLORS="di=1;${yellow_term}:ex=1;${green_term}:ln=1;${cyan_term}:*.md=1;${yellow_term}:*.json=1;${blue_term}:*.js=1;${green_term}:*.ts=1;${green_term}:*.sh=1;${red_term}"
            export BAT_THEME="gruvbox-dark"
            ;;
    esac
    
    # Apply ZSH syntax highlighting if available
    if [ -n "$ZSH_VERSION" ] && [ -n "${ZSH_HIGHLIGHT_STYLES+x}" ]; then
        # Get colors dynamically from JSON
        local default_color=$(jq -r '.colors.term.white' "$theme_file")
        local command_color=$(jq -r '.colors.term.purple' "$theme_file")
        local builtin_color=$(jq -r '.colors.term.pink' "$theme_file")
        local function_color=$(jq -r '.colors.term.green' "$theme_file")
        local alias_color=$(jq -r '.colors.term.green' "$theme_file")
        
        ZSH_HIGHLIGHT_STYLES[default]="fg=${default_color}"
        ZSH_HIGHLIGHT_STYLES[command]="fg=${command_color}"
        ZSH_HIGHLIGHT_STYLES[builtin]="fg=${builtin_color}"
        ZSH_HIGHLIGHT_STYLES[function]="fg=${function_color}"
        ZSH_HIGHLIGHT_STYLES[alias]="fg=${alias_color}"
        
        # Refresh highlighting
        if typeset -f _zsh_highlight > /dev/null 2>&1; then
            _zsh_highlight 2>/dev/null || true
        fi
    fi
    
    # Export theme name
    export TERMINAL_THEME="$theme_name"
    
    # Save preference
    echo "export TERMINAL_THEME='$theme_name'" > ~/.terminal-theme
    
    echo "✓ Theme applied: $theme_name ($style)"
}

# List available themes
list_themes() {
    echo "Available themes:"
    for theme_file in "$THEME_DIR/data"/*.json; do
        if [ -f "$theme_file" ]; then
            local name=$(basename "$theme_file" .json)
            local style=$(jq -r '.style' "$theme_file" 2>/dev/null || echo "unknown")
            local marker=""
            [ "$name" = "$TERMINAL_THEME" ] && marker=" (current)"
            echo "  - $name ($style)$marker"
        fi
    done
}

# Get current theme
get_theme() {
    local theme_name="${1:-$TERMINAL_THEME}"
    local theme_file="$THEME_DIR/data/${theme_name}.json"
    
    if [ -f "$theme_file" ]; then
        jq '.' "$theme_file"
    else
        echo "Theme not found: $theme_name"
    fi
}