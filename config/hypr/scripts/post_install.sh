#!/bin/bash

echo "This script will finalize the installation."

echo "Setting up a wallpaper..."
swww img ~/Pictures/Wallpapers/anime-rose.png -t any --transition-fps 60

echo "Installing Hyprspace plugin..."
hyprpm update
hyprpm add https://github.com/KZDKM/Hyprspace
hyprpm enable Hyprspace
sed -i 's/^#bind = \$mainMod, Tab, overview:toggle, all$/bind = $mainMod, Tab, overview:toggle, all/' ~/.config/hypr/keybinds.conf

echo "Removing post install listener from startup.conf..."
sed -i '/^exec-once = ~\/.config\/hypr\/scripts\/post_install_listener/d' ~/.config/hypr/startup.conf

echo "Post install complete."
zenity --info --text="Post install complete."
