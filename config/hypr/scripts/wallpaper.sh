#!/bin/bash

# Function to execute swww img command for each output
execute_swww_img() {
    image_path=$1
    while IFS= read -r line; do
        output_name=$(echo "$line" | cut -d':' -f1 | sed 's/^[[:space:]]*//')
        swww img "$image_path" -o "$output_name" -t any --transition-fps 60
        cp "$image_path" /usr/share/sddm/themes/sugar-candy/Backgrounds/cache.png
    done < <(swww query)

    # Pywal
    wal -i $image_path -n
    gradience-cli apply -n "pywal" --gtk both
    pkill -f nwg-drawer
    nwg-drawer -r -fm "pcmanfm-qt" -term "kitty" -wm "hyprland" -mt 125 -mb 125 -ml 150 -mr 150 -c 6 -ovl &
}

# Detect monitor resolution and scale
x_mon=$(hyprctl -j monitors | jq '.[] | select(.focused==true) | .width')
y_mon=$(hyprctl -j monitors | jq '.[] | select(.focused==true) | .height')
hypr_scale=$(hyprctl -j monitors | jq '.[] | select (.focused == true) | .scale' | sed 's/\.//')

# Calculate width and height based on percentages and monitor resolution
width=$((x_mon * hypr_scale / 100))
height=$((y_mon * hypr_scale / 100))

# Set maximum width and height
max_width=1200
max_height=1000

# Set percentage of screen size for dynamic adjustment
percentage_width=70
percentage_height=70

# Calculate dynamic width and height
dynamic_width=$((width * percentage_width / 100))
dynamic_height=$((height * percentage_height / 100))

# Limit width and height to maximum values
dynamic_width=$(($dynamic_width > $max_width ? $max_width : $dynamic_width))
dynamic_height=$(($dynamic_height > $max_height ? $max_height : $dynamic_height))

# Go to wallpaper directory
cd ~/Pictures/Wallpapers

# Launch yad with calculated width and height
execute_swww_img "$(yad --width=$dynamic_width --height=$dynamic_height \
    --center \
    --file \
    --add-preview \
    --large-preview \
    --title='Choose a wallpaper')"
