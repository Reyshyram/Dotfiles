#!/bin/bash

# Switch to next keyboard layout
hyprctl switchxkblayout at-translated-set-2-keyboard next

# Get new layout
keyboard_layout=$(hyprctl devices -j | jq -r '.keyboards[] | select(.main == true) | .active_keymap')

# Read pywal accent color
css_file="$HOME/.cache/wal/colors-waybar.css"
color=$(grep -oP "^@define-color accent \K.+" "$css_file" | sed 's/;//')

# Output the actual color value
echo "The true value of the accent color is: $actual_value"
# Create and modify a temporary SVG
temp_svg=$(mktemp /tmp/keyboard_temp.XXXXXX.svg)
cp ~/.config/swaync/icons/keyboard.svg "$temp_svg"
sed -i 's/fill="#FFFFFF"/fill="'$color'"/' "$temp_svg"

# Send notification
notify-send -a keyboard-layout -i "$temp_svg" "Changed keyboard layout" "New layout: $keyboard_layout" -t 3000 --hint=int:transient:1

# Delete temp svg
rm "$temp_svg"
