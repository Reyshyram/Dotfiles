#!/bin/bash

# Pick the color
color=$(hyprpicker -a)


# Verify if color was selected
if [ -n "$color" ]; then
    # Create temporary svg copy
    temp_svg="/tmp/color_picker_temp.svg"
    cp ~/.config/swaync/icons/color-picker.svg "$temp_svg"

    # Modify temp svg color with picked color
    sed -i 's/fill="#FFFFFF"/fill="'$color'"/' "$temp_svg"

    # Send notification
    notify-send -a color-picker -i "$temp_svg" "Color selected" "$color" -t 3000 --hint=int:transient:1

    # Delete temp svg
    rm "$temp_svg"
else
    notify-send -i "$HOME/.config/swaync/icons/color-picker.svg" "Hyprpicker" "No color selected" -t 3000 --hint=int:transient:1
fi