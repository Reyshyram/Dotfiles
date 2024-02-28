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
    while IFS= read -r line; do
        output_name=$(echo "$line" | cut -d':' -f1 | sed 's/^[[:space:]]*//')
        image_path=$(get_random_image)
        swww img "$image_path" -o "$output_name"
        cp "$image_path" /usr/share/sddm/themes/sugar-candy/Backgrounds/cache.png
    done < <(swww query)
}

# Execute swww img and copy images initially
execute_swww_img

# Loop to execute the script every hour
while true; do
    sleep 1h
    execute_swww_img
done
