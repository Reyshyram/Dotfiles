#!/bin/bash

# Notify
notify_user() {
    pw-play "$HOME/.config/swaync/sounds/audio-volume-change.oga"
}

# Increase Volume
inc_volume() {
    swayosd-client --output-volume 5 && notify_user
}

# Decrease Volume
dec_volume() {
    swayosd-client --output-volume -5 && notify_user
}

# Toggle Mute
toggle_mute() {
	swayosd-client --output-volume mute-toggle
}

# Toggle Mic
toggle_mic() {
	swayosd-client --input-volume mute-toggle
}

# Execute accordingly
if [[ "$1" == "--inc" ]]; then
	inc_volume
elif [[ "$1" == "--dec" ]]; then
	dec_volume
elif [[ "$1" == "--toggle" ]]; then
	toggle_mute
elif [[ "$1" == "--toggle-mic" ]]; then
	toggle_mic
fi