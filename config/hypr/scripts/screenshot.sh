#!/bin/bash

directory="$HOME/Pictures/Screenshots"

if [ ! -d "$directory" ]; then
  mkdir -p "$directory"
fi

notify() {
    # Create temporary svg copy
    temp_svg="/tmp/screenshot.svg"
    cp ~/.config/swaync/icons/screenshot.svg "$temp_svg"

    # Read pywal accent color
    color=$(sed -n '10p' ~/.cache/wal/colors)

    # Modify temp svg color with pywal color
    sed -i 's/fill="#FFFFFF"/fill="'$color'"/' "$temp_svg"
    sed -i 's/stroke="#FFFFFF"/stroke="'$color'"/' "$temp_svg"

    # Send notification with action
    action=$(notify-send -i "$temp_svg" "Screenshot copied" "Screenshot saved under ~/Pictures/Screenshots/screenshot_$timestamp.png" -t 5000 -A "swappy=Edit Screenshot")

    # Delete temp svg
    rm "$temp_svg"

    # Handle action
    if [[ "$action" == "swappy" ]]; then
        swappy -f "$directory/screenshot_$timestamp.png"
    fi
}

save_screenshot() {
    timestamp=$(date +"%Y-%m-%d_%H-%M-%S")
    mv /tmp/screenshot.png "$directory/screenshot_$timestamp.png"
}

current_monitor() {
    grimblast copysave output /tmp/screenshot.png
    save_screenshot
    notify
}

all_monitors() {
    grimblast copysave screen /tmp/screenshot.png
    save_screenshot
    notify
}

area() {
    grimblast copysave area /tmp/screenshot.png
    save_screenshot
    notify
}

frozen_area() {
    grimblast --freeze copysave area /tmp/screenshot.png
    save_screenshot
    notify
}

# Execute accordingly
if [[ "$1" == "--current-monitor" ]]; then
    current_monitor
elif [[ "$1" == "--all-monitors" ]]; then
    all_monitors
elif [[ "$1" == "--area" ]]; then
    area
elif [[ "$1" == "--frozen-area" ]]; then
    frozen_area
fi
