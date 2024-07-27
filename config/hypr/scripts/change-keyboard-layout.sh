#!/bin/bash

# Change keyboard layout
hyprctl switchxkblayout at-translated-set-2-keyboard next

# Get new layout
keyboard_layout=$(hyprctl devices -j | jq -r '.keyboards[] | select(.main == true) | .active_keymap')

# Read pywal accent color
color=$(sed -n '10p' ~/.cache/wal/colors)

# Create temporary copy
temp_svg="/tmp/keyboard_temp.svg"
cp ~/.config/swaync/icons/keyboard.svg "$temp_svg"

# Modify temp svg color
sed -i "s/fill=\"[^\"]*\"/fill=\"$color\"/" "$temp_svg"

# Send notification
notify-send -i "$temp_svg" "Changed keyboard layout" "New layout: $keyboard_layout" -t 3000 --hint=int:transient:1

# Delete temp svg
rm "$temp_svg"
