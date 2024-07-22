#!/bin/bash

# Notify
notify_user() {
    theme="freedesktop" # Set the theme for the system sounds.

    # Set the directory defaults for system sounds.
    userDIR="$HOME/.local/share/sounds"
    systemDIR="/usr/share/sounds"
    defaultTheme="freedesktop"

    # Prefer the user's theme, but use the system's if it doesn't exist.
    sDIR="$systemDIR/$defaultTheme"
    if [ -d "$userDIR/$theme" ]; then
        sDIR="$userDIR/$theme"
    elif [ -d "$systemDIR/$theme" ]; then
        sDIR="$systemDIR/$theme"
    fi

    # Get the theme that it inherits.
    iTheme=$(grep -i "inherits" "$sDIR/index.theme" | cut -d "=" -f 2)
    iDIR="$sDIR/../$iTheme"

    # Find the volume change sound file and play it.
    sound_file=$(find $sDIR/stereo -name "audio-volume-change.*" -print -quit)
    if ! test -f "$sound_file"; then
        sound_file=$(find $iDIR/stereo -name "audio-volume-change.*" -print -quit)
        if ! test -f "$sound_file"; then
            sound_file=$(find $userDIR/$defaultTheme/stereo -name "audio-volume-change.*" -print -quit)
            if ! test -f "$sound_file"; then
                sound_file=$(find $systemDIR/$defaultTheme/stereo -name "audio-volume-change.*" -print -quit)
                if ! test -f "$sound_file"; then
                    echo "Error: Sound file not found."
                    exit 1
                fi
            fi
        fi
    fi

    pw-play "$sound_file"
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