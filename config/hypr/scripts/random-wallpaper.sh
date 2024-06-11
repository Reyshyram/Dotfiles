#!/bin/bash

# Function to get a random PNG image path from ~/Pictures/Wallpapers directory
get_random_image() {
    shopt -s nullglob
    images=(~/Pictures/Wallpapers/*.png)
    num_images=${#images[@]}
    if [ "$num_images" -gt 0 ]; then
        rand_index=$((RANDOM % num_images))
        echo "${images[$rand_index]}"
    else
        echo "No PNG images found in ~/Pictures/Wallpapers directory."
        exit 1
    fi
}

# Function to execute swww img command for each output
execute_swww_img() {
    image_path=$(get_random_image)
    while IFS= read -r line; do
        output_name=$(echo "$line" | cut -d':' -f1 | sed 's/^[[:space:]]*//')
        swww img "$image_path" -o "$output_name" -t any --transition-fps 60
        cp "$image_path" /usr/share/sddm/themes/sugar-candy/Backgrounds/cache.png
    done < <(swww query)

    # Pywal
    wal --cols16 -i $image_path -n
    gradience-cli apply -n "pywal" --gtk both
    pkill -f nwg-drawer
    nwg-drawer -r -fm "pcmanfm-qt" -term "kitty" -wm "hyprland" -mt 125 -mb 125 -ml 150 -mr 150 -c 6 -ovl &
    swaync-client -rs
    killall -SIGUSR2 waybar
}

# Random wallpaper
execute_swww_img
