#!/bin/bash

# Theme Manager - Single source of truth for terminal colors
# Pure shell implementation without Node.js dependency

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
THEME_FILE="$HOME/.terminal-theme"
CURRENT_THEME="cyberpunk"

# Load saved theme preference
if [ -f "$THEME_FILE" ]; then
    source "$THEME_FILE" 2>/dev/null
    [ -n "$TERMINAL_THEME" ] && CURRENT_THEME="$TERMINAL_THEME"
fi

# Function to get theme data
get_theme() {
    local theme_name="${1:-$CURRENT_THEME}"
    local theme_file="$SCRIPT_DIR/data/${theme_name}.json"
    
    if [ ! -f "$theme_file" ]; then
        echo "Error: Theme '$theme_name' not found" >&2
        return 1
    fi
    
    cat "$theme_file"
}

# Function to list available themes
list_themes() {
    echo "Available themes:"
    for theme_file in "$SCRIPT_DIR/data"/*.json; do
        if [ -f "$theme_file" ]; then
            local name=$(basename "$theme_file" .json)
            local style=$(grep '"style"' "$theme_file" | cut -d'"' -f4)
            local marker=""
            [ "$name" = "$CURRENT_THEME" ] && marker=" (current)"
            echo "  - $name ($style)$marker"
        fi
    done
}

# Function to set theme
set_theme() {
    local theme_name="$1"
    
    if [ -z "$theme_name" ]; then
        echo "Error: Theme name required" >&2
        return 1
    fi
    
    if [ ! -f "$SCRIPT_DIR/data/${theme_name}.json" ]; then
        echo "Error: Theme '$theme_name' not found" >&2
        return 1
    fi
    
    # Save theme preference
    echo "export TERMINAL_THEME='$theme_name'" > "$THEME_FILE"
    CURRENT_THEME="$theme_name"
    echo "Theme set to: $theme_name"
}

# Function to apply theme (output shell variables)
apply_theme() {
    local theme_name="${1:-$CURRENT_THEME}"
    local theme_file="$SCRIPT_DIR/data/${theme_name}.json"
    
    if [ ! -f "$theme_file" ]; then
        echo "Error: Theme '$theme_name' not found" >&2
        return 1
    fi
    
    # Parse JSON and output shell variables
    # Extract ANSI colors
    echo "# Theme: $theme_name"
    
    # Parse colors from JSON and unescape the backslashes
    # Extract and process ANSI colors (removing the double backslash)
    grep '"purple"' "$theme_file" | head -1 | sed 's/.*"purple": *"\(.*\)".*/\1/' | sed 's/\\\\033/\\033/g' | sed "s/.*/export PURPLE='&'/"
    grep '"green"' "$theme_file" | head -1 | sed 's/.*"green": *"\(.*\)".*/\1/' | sed 's/\\\\033/\\033/g' | sed "s/.*/export GREEN='&'/"
    grep '"cyan"' "$theme_file" | head -1 | sed 's/.*"cyan": *"\(.*\)".*/\1/' | sed 's/\\\\033/\\033/g' | sed "s/.*/export CYAN='&'/"
    grep '"pink"' "$theme_file" | head -1 | sed 's/.*"pink": *"\(.*\)".*/\1/' | sed 's/\\\\033/\\033/g' | sed "s/.*/export PINK='&'/"
    grep '"yellow"' "$theme_file" | head -1 | sed 's/.*"yellow": *"\(.*\)".*/\1/' | sed 's/\\\\033/\\033/g' | sed "s/.*/export YELLOW='&'/"
    grep '"red"' "$theme_file" | head -1 | sed 's/.*"red": *"\(.*\)".*/\1/' | sed 's/\\\\033/\\033/g' | sed "s/.*/export RED='&'/"
    grep '"orange"' "$theme_file" | head -1 | sed 's/.*"orange": *"\(.*\)".*/\1/' | sed 's/\\\\033/\\033/g' | sed "s/.*/export ORANGE='&'/"
    grep '"blue"' "$theme_file" | head -1 | sed 's/.*"blue": *"\(.*\)".*/\1/' | sed 's/\\\\033/\\033/g' | sed "s/.*/export BLUE='&'/"
    grep '"comment"' "$theme_file" | head -1 | sed 's/.*"comment": *"\(.*\)".*/\1/' | sed 's/\\\\033/\\033/g' | sed "s/.*/export COMMENT='&'/"
    grep '"white"' "$theme_file" | head -1 | sed 's/.*"white": *"\(.*\)".*/\1/' | sed 's/\\\\033/\\033/g' | sed "s/.*/export WHITE='&'/"
    grep '"background"' "$theme_file" | head -1 | sed 's/.*"background": *"\(.*\)".*/\1/' | sed 's/\\\\033/\\033/g' | sed "s/.*/export BACKGROUND='&'/"
    grep '"selection"' "$theme_file" | head -1 | sed 's/.*"selection": *"\(.*\)".*/\1/' | sed 's/\\\\033/\\033/g' | sed "s/.*/export SELECTION='&'/"
    
    echo "export NC='\\033[0m'"
    
    # Parse RGB values - skip for now to keep it simple
    # RGB values would be extracted similarly if needed
    
    # Parse HEX values - skip for now to keep it simple
    # HEX values would be extracted similarly if needed
    
    # Theme metadata
    echo "export THEME_NAME='$theme_name'"
    local style=$(grep '"style"' "$theme_file" | cut -d'"' -f4)
    echo "export THEME_STYLE='$style'"
}

# Show help
show_help() {
    cat << EOF
Theme Manager - Single source of truth for terminal colors

Usage: theme <command> [options]

Commands:
  list              List all available themes
  get [name]        Get current or specified theme
  set <name>        Set active theme
  apply             Apply current theme (outputs shell variables)
  export <file>     Export theme variables to file
  
Examples:
  theme list                    # Show all themes
  theme set dracula            # Switch to Dracula theme  
  theme apply > ~/.theme       # Export for shell sourcing
  source <(theme apply)        # Apply directly in shell
EOF
}

# Main command processing
COMMAND="${1:-help}"
shift 2>/dev/null || true

case "$COMMAND" in
    list)
        list_themes
        ;;
        
    get)
        get_theme "$1"
        ;;
        
    set)
        set_theme "$1"
        ;;
        
    apply)
        apply_theme "$1"
        ;;
        
    export)
        if [ -z "$1" ]; then
            echo "Error: Output file required" >&2
            exit 1
        fi
        apply_theme > "$1"
        echo "Theme exported to: $1"
        ;;
        
    help|--help|-h)
        show_help
        ;;
        
    *)
        show_help
        exit 1
        ;;
esac