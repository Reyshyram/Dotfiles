#!/bin/bash

sound_file="$HOME/.config/swaync/sounds/notification.ogg"

# Do not play the sound if the notification is coming from one of these apps
excluded_apps=("keyboard-layout" "screenshot" "color-picker")

# Verify if SWAYNC_APP_NAME is defined
if [ -n "$SWAYNC_APP_NAME" ]; then
    # Verify if SWAYNC_APP_NAME isn't a part of the excluded apps
    if [[ ! " ${excluded_apps[@]} " =~ " ${SWAYNC_APP_NAME} " ]]; then
        # Play notification sound
        pw-play "$sound_file"
    fi
else
    # Always play notification sound if SWAYNC_APP_NAME isn't defined
    pw-play "$sound_file"
fi
