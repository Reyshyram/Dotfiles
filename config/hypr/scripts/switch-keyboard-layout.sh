#!/bin/bash

# Switch to next keyboard layout
hyprctl switchxkblayout current next

# Get new layout
keyboard_layout=$(hyprctl devices -j | jq -r '.keyboards[] | select(.main == true) | .active_keymap')

# Send notification
swayosd-client --custom-message $keyboard_layout --custom-icon input-keyboard-virtual-on