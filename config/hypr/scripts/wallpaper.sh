#!/bin/bash

# Cache directory for PNG images
CACHE_DIR="$HOME/.cache/converted_images"
mkdir -p "$CACHE_DIR"

# Function to compute the hash of an image file
compute_hash() {
    local input_image="$1"
    sha256sum "$input_image" | awk '{ print $1 }'
}

# Function to get a random image path from the ~/Pictures/Wallpapers directory
get_random_image() {
    shopt -s nullglob
    local image_files=($HOME/Pictures/Wallpapers/*.{jpeg,jpg,png,gif,pnm,tga,tiff,webp,bmp,farbfeld})
    local image_count=${#image_files[@]}
    
    if (( image_count > 0 )); then
        local random_index=$((RANDOM % image_count))
        echo "${image_files[$random_index]}"
    else
        echo "No images found in $HOME/Pictures/Wallpapers directory."
        exit 1
    fi
}

# Function to convert image to PNG format if it's not already
convert_to_png() {
    local input_image="$1"
    local hash=$(compute_hash "$input_image")
    local output_image="$CACHE_DIR/${hash}.png"

    # Check if the converted image already exists in the cache
    if [[ ! -f "$output_image" ]]; then
        if [[ "$input_image" == *.gif ]]; then
            # Convert only the first frame of GIF to PNG
            magick convert "$input_image[0]" "$output_image"
        else
            # Convert image to PNG using ImageMagick
            magick "$input_image" "$output_image"
        fi
    fi

    echo "$output_image"
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

    converted_image=$(convert_to_png "$image_path")
    
    cp "$converted_image" /usr/share/sddm/themes/sugar-candy/Backgrounds/cache.png

    # Pywal
    wal --cols16 -i "$converted_image" -n -e -q --backend haishoku
    python "$HOME/.config/hypr/scripts/pywal-accent-color.py" "$converted_image"

    gradience-cli apply -n "pywal" --gtk both
    
    pkill -f nwg-drawer
    nwg-drawer -r -fm "pcmanfm-qt" -term "kitty" -wm "hyprland" -mt 84 -mb 50 -ml 50 -mr 50 -c 6 -nocats -nofs -ovl &
    
    swaync-client -rs
    killall -SIGUSR2 waybar

    pywalfox update
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
    monitor_width=$((x_mon * hypr_scale / 100))
    monitor_height=$((y_mon * hypr_scale / 100))

    # Set percentage of screen size for dynamic adjustment
    percentage_width=75
    percentage_height=75

    # Calculate dynamic width and height
    dynamic_width=$((monitor_width * percentage_width / 100))
    dynamic_height=$((monitor_height * percentage_height / 100))

    cd ~/Pictures/Wallpapers

    # Launch yad with calculated width and height for user to select an image
    selected_image=$(yad --width="$dynamic_width" --height="$dynamic_height" \
        --center \
        --file \
        --add-preview \
        --large-preview \
        --title='Choose a wallpaper')
fi

# Convert image to PNG if necessary
if [[ -n "$selected_image" ]]; then
    apply_wallpaper "$selected_image"
fi
