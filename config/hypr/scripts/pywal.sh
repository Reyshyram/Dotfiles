#!/bin/bash

# Cache directory for PNG images
CACHE_DIR="$HOME/.cache/converted_images"
mkdir -p "$CACHE_DIR"

# Function to compute the hash of an image file
compute_hash() {
    local input_image="$1"
    sha256sum "$input_image" | awk '{ print $1 }'
}

# Function to convert image to PNG format if it's not already
convert_to_png() {
    local input_image="$1"

    # If the image is already a PNG, return the input image path
    if [[ "$input_image" == *.png ]]; then
        echo "$input_image"
        return
    fi

    local hash=$(compute_hash "$input_image")
    local output_image="$CACHE_DIR/${hash}.png"

    # Check if the converted image already exists in the cache
    if [[ ! -f "$output_image" ]]; then
        if [[ "$input_image" == *.gif ]]; then
            # Convert only the first frame of GIF to PNG
            magick "$input_image[0]" "$output_image"
        else
            # Convert image to PNG using ImageMagick
            magick "$input_image" "$output_image"
        fi
    fi

    echo "$output_image"
}

apply_pywal() {
    local image_path="$1"

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

# Check if image path is provided
if [[ -z "$1" ]]; then
    echo "Usage: $0 <path-to-wallpaper>"
    exit 1
fi

apply_pywal "$1"