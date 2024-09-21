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
    
    cp "$converted_image" /usr/share/sddm/themes/sddm-astronaut/background.png

    # Pywal

    # Prevent hyprland error message
    sed -i '/    suppress_errors = false/c\    suppress_errors = true' ~/.config/hypr/misc.conf

    wal --cols16 -i "$converted_image" -n -e -q --backend haishoku
    python "$HOME/.config/hypr/scripts/pywal-accent-color.py" "$converted_image"

    # Reactivate hyprland error messages
    sed -i '/    suppress_errors = true/c\    suppress_errors = false' ~/.config/hypr/misc.conf

    pkill -f nwg-drawer
    nwg-drawer -r -fm "pcmanfm-qt" -term "kitty" -wm "hyprland" -mt 92 -mb 50 -ml 50 -mr 50 -c 6 -nocats -nofs -ovl &
    
    swaync-client -rs

    # pywalfox update

    # SDDM colors
    background_color=$(sed -n '1p' ~/.cache/wal/colors)
    accent_color=$(sed -n '17p' ~/.cache/wal/colors)

    sed -i "s/^BackgroundColor=\".*\"/BackgroundColor=\"$background_color\"/" /usr/share/sddm/themes/sddm-astronaut/theme.conf
    sed -i "s/^AccentColor=\".*\"/AccentColor=\"$accent_color\"/" /usr/share/sddm/themes/sddm-astronaut/theme.conf

    # OpenRGB Color
    openrgb -c ${accent_color:1}
}

# Check if image path is provided
if [[ -z "$1" ]]; then
    echo "Usage: $0 <path-to-wallpaper>"
    exit 1
fi

apply_pywal "$1"
