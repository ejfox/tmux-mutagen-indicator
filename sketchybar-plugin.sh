#!/usr/bin/env bash

# Sketchybar plugin for Mutagen status
# Place this file in ~/.config/sketchybar/plugins/

PLUGIN_DIR=$(dirname "$0")
MUTAGEN_SCRIPT="$PLUGIN_DIR/mutagen-indicator.sh"

# Try different common locations
if [ ! -f "$MUTAGEN_SCRIPT" ]; then
    if [ -f "$PLUGIN_DIR/../../../tmux-mutagen-indicator/mutagen-indicator.sh" ]; then
        MUTAGEN_SCRIPT="$PLUGIN_DIR/../../../tmux-mutagen-indicator/mutagen-indicator.sh"
    elif command -v mutagen-indicator.sh >/dev/null 2>&1; then
        MUTAGEN_SCRIPT="mutagen-indicator.sh"
    else
        echo "Error: mutagen-indicator.sh not found" >&2
        exit 1
    fi
fi

# Export format for Sketchybar
export MUTAGEN_OUTPUT_FORMAT="sketchybar"

# Get status from mutagen indicator
STATUS_JSON=$($MUTAGEN_SCRIPT)

# Parse JSON output
TEXT=$(echo "$STATUS_JSON" | grep -o '"text":"[^"]*"' | cut -d'"' -f4)
TOOLTIP=$(echo "$STATUS_JSON" | grep -o '"tooltip":"[^"]*"' | cut -d'"' -f4)
COLOR=$(echo "$STATUS_JSON" | grep -o '"color":"[^"]*"' | cut -d'"' -f4)

# Update Sketchybar item
sketchybar --set "$NAME" \
    label="$TEXT" \
    icon.color="$COLOR" \
    label.color="$COLOR" \
    click_script="open -a 'Terminal' && echo 'mutagen sync list'" \
    tooltip="$TOOLTIP"