#!/bin/bash

# Switch to next keyboard layout
hyprctl switchxkblayout current next

# Get new layout
keyboard_layout=$(hyprctl devices -j | jq -r '.keyboards[] | select(.main == true) | .active_keymap')

# Read pywal accent color
color=$(sed -n '17p' ~/.cache/wal/colors)

# Create and modify a temporary SVG
temp_svg=$(mktemp /tmp/keyboard_temp.XXXXXX.svg)
cp ~/.config/swaync/icons/keyboard.svg "$temp_svg"
sed -i 's/fill="#FFFFFF"/fill="'$color'"/' "$temp_svg"

# Send notification
notify-send -a keyboard-layout -i "$temp_svg" "Changed keyboard layout" "New layout: $keyboard_layout" -t 3000 --hint=int:transient:1 \
    --hint=string:x-canonical-private-synchronous:keyboard_notif

# Delete temp svg
rm "$temp_svg"
