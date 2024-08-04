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
    image_path=$1

    # Set wallpaper
    while IFS= read -r line; do
        output_name=$(echo "$line" | cut -d':' -f1 | sed 's/^[[:space:]]*//')
        swww img "$image_path" -o "$output_name" -t any --transition-fps 60
    done < <(swww query)
    cp "$image_path" /usr/share/sddm/themes/sugar-candy/Backgrounds/cache.png

    # Pywal
    wal --cols16 -i $image_path -n -e -q --backend haishoku
    cd ~/.config/hypr/scripts
    source ./pywal-accent-color-env/bin/activate
    python pywal-accent-color.py $image_path
    deactivate
    gradience-cli apply -n "pywal" --gtk both
    pkill -f nwg-drawer
    nwg-drawer -r -fm "pcmanfm-qt" -term "kitty" -wm "hyprland" -mt 125 -mb 65 -ml 65 -mr 65 -c 5 -ovl &
    swaync-client -rs
    killall -SIGUSR2 waybar
}

# Check for virtual env
cd ~/.config/hypr/scripts
if [ ! -d "pywal-accent-color-env" ]; then
    ./pywal-accent-color-setup.sh
fi


# Check for --random flag
if [ "$1" == "--random" ]; then
    selected_image=$(get_random_image)
else
    # Detect monitor resolution and scale
    x_mon=$(hyprctl -j monitors | jq '.[] | select(.focused==true) | .width')
    y_mon=$(hyprctl -j monitors | jq '.[] | select(.focused==true) | .height')
    hypr_scale=$(hyprctl -j monitors | jq '.[] | select (.focused == true) | .scale' | sed 's/\.//')

    # Calculate width and height based on percentages and monitor resolution
    width=$((x_mon * hypr_scale / 100))
    height=$((y_mon * hypr_scale / 100))

    # Set percentage of screen size for dynamic adjustment
    percentage_width=70
    percentage_height=70

    # Calculate dynamic width and height
    dynamic_width=$((width * percentage_width / 100))
    dynamic_height=$((height * percentage_height / 100))

    # Go to wallpaper directory
    cd ~/Pictures/Wallpapers

    # Launch yad with calculated width and height for user to select an image
    selected_image=$(yad --width=$dynamic_width --height=$dynamic_height \
        --center \
        --file \
        --add-preview \
        --large-preview \
        --title='Choose a wallpaper')
fi

# Execute the swww img command with the chosen or random image
if [ "$selected_image" ]; then
    execute_swww_img "$selected_image"
fi