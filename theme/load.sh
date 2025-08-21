#!/bin/bash

# Theme loader - Sources theme colors into current shell
# Usage: source theme/load.sh [theme_name]

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
THEME_NAME="${1:-dracula}"

# Check if node is available
if ! command -v node &> /dev/null; then
    echo "Error: Node.js is required for theme system"
    return 1 2>/dev/null || exit 1
fi

# Apply theme and source variables
eval "$(node "$SCRIPT_DIR/cli.js" set "$THEME_NAME" > /dev/null && node "$SCRIPT_DIR/cli.js" apply)"

# Verify theme loaded
if [ -n "$THEME_NAME" ]; then
    echo "Theme loaded: $THEME_NAME ($THEME_STYLE)"
else
    echo "Error: Failed to load theme"
    return 1 2>/dev/null || exit 1
fi