#!/bin/bash

# Pick the color
color=$(hyprpicker -a)

# Ensure a color was selected
if [ -n "$color" ]; then
    temp_svg=$(mktemp /tmp/color_picker_temp.XXXXXX.svg)
    cp ~/.config/swaync/icons/color-picker.svg "$temp_svg"
    sed -i 's/fill="#FFFFFF"/fill="'$color'"/' "$temp_svg"
    notify-send -a color-picker -i "$temp_svg" "Color selected" "$color" -t 3000 --hint=int:transient:1
    rm "$temp_svg"
else
    notify-send -a color-picker -i "$HOME/.config/swaync/icons/color-picker.svg" "Hyprpicker" "No color selected" -t 3000 --hint=int:transient:1
fi
