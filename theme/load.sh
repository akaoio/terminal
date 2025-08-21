#!/bin/bash

# Theme loader - Sources theme colors into current shell
# Usage: source theme/load.sh [theme_name]

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
THEME_NAME="${1:-dracula}"

# Check if theme CLI exists
if [ ! -f "$SCRIPT_DIR/cli.sh" ]; then
    echo "Error: Theme CLI not found"
    return 1 2>/dev/null || exit 1
fi

# Apply theme and source variables
"$SCRIPT_DIR/cli.sh" set "$THEME_NAME" > /dev/null 2>&1
eval "$("$SCRIPT_DIR/cli.sh" apply)"

# Verify theme loaded
if [ -n "$THEME_NAME" ]; then
    echo "Theme loaded: $THEME_NAME ($THEME_STYLE)"
else
    echo "Error: Failed to load theme"
    return 1 2>/dev/null || exit 1
fi