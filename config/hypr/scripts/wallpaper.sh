#!/bin/bash

# Function to get a random PNG image path from the ~/Pictures/Wallpapers directory
get_random_image() {
    shopt -s nullglob
    local image_files=($HOME/Pictures/Wallpapers/*.png)
    local image_count=${#image_files[@]}
    
    if (( image_count > 0 )); then
        local random_index=$((RANDOM % image_count))
        echo "${image_files[$random_index]}"
    else
        echo "No PNG images found in $HOME/Pictures/Wallpapers directory."
        exit 1
    fi
}

# Function to execute swww img command for each output
apply_wallpaper() {
    local image_path="$1"

    # Set wallpaper
    while IFS= read -r line; do
        local output_name
        output_name=$(echo "$line" | cut -d':' -f1 | sed 's/^[[:space:]]*//')
        swww img "$image_path" -o "$output_name" -t any --transition-fps 60
    done < <(swww query)
    
    cp "$image_path" /usr/share/sddm/themes/sugar-candy/Backgrounds/cache.png

    # Pywal
    wal --cols16 -i "$image_path" -n -e -q --backend haishoku
    python "$HOME/.config/hypr/scripts/pywal-accent-color.py" "$image_path"

    gradience-cli apply -n "pywal" --gtk both
    
    pkill -f nwg-drawer
    nwg-drawer -r -fm "pcmanfm-qt" -term "kitty" -wm "hyprland" -mt 100 -mb 50 -ml 50 -mr 50 -c 6 -nocats -nofs -ovl &
    
    swaync-client -rs
    killall -SIGUSR2 waybar
}

# Check for --random flag
if [[ "$1" == "--random" ]]; then
    selected_image=$(get_random_image)
else
    # Get monitor resolution and scale
    x_mon=$(hyprctl -j monitors | jq '.[] | select(.focused==true) | .width')
    y_mon=$(hyprctl -j monitors | jq '.[] | select(.focused==true) | .height')
    hypr_scale=$(hyprctl -j monitors | jq '.[] | select (.focused == true) | .scale' | sed 's/\.//')

    # Calculate width and height based on percentages and monitor resolution
    local monitor_width=$((x_mon * hypr_scale / 100))
    local monitor_height=$((y_mon * hypr_scale / 100))

    # Set percentage of screen size for dynamic adjustment
    local percentage_width=70
    local percentage_height=70

    # Calculate dynamic width and height
    local dynamic_width=$((monitor_width * percentage_width / 100))
    local dynamic_height=$((monitor_height * percentage_height / 100))

    # Launch yad with calculated width and height for user to select an image
    selected_image=$(yad --width="$dynamic_width" --height="$dynamic_height" \
        --center \
        --file \
        --add-preview \
        --large-preview \
        --title='Choose a wallpaper')
fi

# Execute the apply_wallpaper function with the selected image
if [[ -n "$selected_image" ]]; then
    apply_wallpaper "$selected_image"
fi