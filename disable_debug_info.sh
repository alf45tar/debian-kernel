#!/bin/bash

# Path to the config file
CONFIG_FILE="debian/config/armhf/defines"
DEBUG_INFO_LINE="debug-info: false"

# Check if the file exists
if [ ! -f "$CONFIG_FILE" ]; then
    echo "File $CONFIG_FILE does not exist."
    exit 1
fi

# Backup the original file
cp "$CONFIG_FILE" "$CONFIG_FILE.bak"

# Check if the debug-info line exists and replace it
if grep -q "debug-info" "$CONFIG_FILE"; then
    sed -i "s/^debug-info:.*/$DEBUG_INFO_LINE/" "$CONFIG_FILE"
    echo "Replaced existing debug-info line with: $DEBUG_INFO_LINE"
else
    # Add debug-info: false to the [build] section
    awk -v debug_info_line="$DEBUG_INFO_LINE" '/\[build\]/{print; print debug_info_line; next}1' "$CONFIG_FILE" > "$CONFIG_FILE.tmp" && mv "$CONFIG_FILE.tmp" "$CONFIG_FILE"
    echo "Added $DEBUG_INFO_LINE to the [build] section in $CONFIG_FILE."
fi
