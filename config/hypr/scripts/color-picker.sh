#!/bin/bash

# Pick the color
color=$(hyprpicker -a)

# Ensure a color was selected
if [ -n "$color" ]; then
    swayosd-client --custom-message "Selected $color" --custom-icon gtk-color-picker
else
    swayosd-client --custom-message "No color selected" --custom-icon gtk-color-picker
fi
