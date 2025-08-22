#!/bin/bash

# Theme loader - Sources theme colors into current shell
# Usage: source theme/load.sh [theme_name]

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
THEME_NAME="${1:-dracula}"

# Check if theme CLI exists
if [ ! -f "$SCRIPT_DIR/cli.sh" ]; then
    # Silently fail - don't output errors
    return 0 2>/dev/null || exit 0
fi

# Don't set theme (which might hang), just apply colors
# The 'set' operation writes to disk and isn't needed for color loading
# "$SCRIPT_DIR/cli.sh" set "$THEME_NAME" > /dev/null 2>&1  # REMOVED - causes hanging

# Apply theme colors directly without blocking operations
if [ -f "$SCRIPT_DIR/data/${THEME_NAME}.json" ]; then
    # Export theme colors by sourcing the apply command
    eval "$("$SCRIPT_DIR/cli.sh" apply "$THEME_NAME" 2>/dev/null)" || true
fi

# Success - no output to avoid SSH issues
return 0 2>/dev/null || exit 0