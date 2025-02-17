#!/bin/bash

directory="$HOME/Pictures/Screenshots"
temp_svg=$(mktemp /tmp/screenshot.XXXXXX.svg)

# Ensure screenshot directory exists
mkdir -p "$directory"

# Function to create and modify a temporary SVG
create_temp_svg() {
    cp ~/.config/swaync/icons/screenshot.svg "$temp_svg"
    
    # Read accent color
    color=$(sed -n '1p' ~/.cache/wal/accent-color)

    sed -i -e 's/fill="#FFFFFF"/fill="'$color'"/' -e 's/stroke="#FFFFFF"/stroke="'$color'"/' "$temp_svg"
}

# Function to send a notification with an action
send_notification() {
    action=$(notify-send -a screenshot -i "$temp_svg" "Screenshot copied" "Screenshot saved under ~/Pictures/Screenshots/screenshot_$timestamp.png" -t 5000 -A "pinta=Edit Screenshot")
    [[ "$action" == "pinta" ]] && pinta "$directory/screenshot_$timestamp.png"
    rm "$temp_svg"
}

# Function to save the screenshot
save_screenshot() {
    timestamp=$(date +"%Y-%m-%d_%H-%M-%S")
    mv /tmp/screenshot.png "$directory/screenshot_$timestamp.png"
}

# Function to handle screenshot actions
take_screenshot() {
    local type="$1"
    grimblast copysave "$type" /tmp/screenshot.png
    save_screenshot
    create_temp_svg
    send_notification
}

# Main script execution
case "$1" in
    --current-monitor) take_screenshot output ;;
    --all-monitors) take_screenshot screen ;;
    --area) take_screenshot area ;;
    --frozen-area) grimblast --freeze copysave area /tmp/screenshot.png; save_screenshot; create_temp_svg; send_notification ;;
    *) echo "Usage: $0 {--current-monitor|--all-monitors|--area|--frozen-area}" ;;
esac
