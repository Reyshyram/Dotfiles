#!/bin/bash

# Configuration
sound_file="$HOME/.config/swaync/sounds/notification.ogg"
last_play_file="/tmp/last_notification_play"
excluded_apps=("keyboard-layout" "screenshot" "color-picker")

# Function to play notification sound
play_sound() {
    pw-play "$sound_file"
    date +%s > "$last_play_file"
}

# Function to check if a sound can be played (not played in the last 3 seconds)
can_play_sound() {
    if [ ! -f "$last_play_file" ]; then
        return 0
    fi

    local last_play
    last_play=$(cat "$last_play_file")
    local current_time
    current_time=$(date +%s)

    if (( current_time - last_play >= 3 )); then
        return 0
    else
        return 1
    fi
}

# Function to check if the app is in the excluded list
is_excluded_app() {
    local app_name=$1
    for app in "${excluded_apps[@]}"; do
        if [[ "$app" == "$app_name" ]]; then
            return 0
        fi
    done
    return 1
}

# Main logic
if [[ -n "${SWAYNC_APP_NAME:-}" ]]; then
    if ! is_excluded_app "$SWAYNC_APP_NAME"; then
        if can_play_sound; then
            play_sound
        fi
    fi
else
    if can_play_sound; then
        play_sound
    fi
fi
