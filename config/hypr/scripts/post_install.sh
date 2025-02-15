#!/bin/bash

echo "This script will finalize the installation."

echo "Setting up a wallpaper..."
swww img ~/Pictures/Wallpapers/anime-rose.png -t any --transition-fps 60

echo "Installing Hyprspace plugin..."
hyprpm update
hyprpm add https://github.com/Duckonaut/split-monitor-workspaces
hyprpm enable split-monitor-workspaces
hyprpm add https://github.com/hyprwm/hyprland-plugins
hyprpm enable hyprexpo
hyprpm reload

echo "Removing post install listener from startup.conf..."
sed -i '/^exec-once = ~\/.config\/hypr\/scripts\/post_install_listener.sh/d' ~/.config/hypr/startup.conf

echo "Post install complete."
zenity --info --text="Post install complete."
