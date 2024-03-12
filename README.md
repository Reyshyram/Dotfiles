
# Installation

>[!CAUTION]
>The installation script is meant to be used on a minimal Arch installation with grub and systemd. It will replace any existing configuration. Please proceed with caution.

First, update your system.
```
sudo pacman -Syu
```

Then, install git.
```
sudo pacman -S git
```

After that, you can now clone the repository:
```
git clone https://github.com/Reyshyram/Dotfiles.git
```

Then, cd into the directory containing the dotfiles:
```
cd Dotfiles
```

Finally, make sure the install script has the required permissions and launch it.
```
chmod +x ./install.sh && ./install.sh
```

Follow the instructions on your terminal. If there's a problem, feel free to open an issue.

>[!IMPORTANT]
>If you are using a Nvidia GPU, please follow the instructions on the [Hyprland wiki](https://wiki.hyprland.org/Nvidia/) before rebooting.



## Informations

This rice relies heavily on the [Catppuccin Mocha](https://github.com/catppuccin/catppuccin) color scheme.
You can show a list of keybinds using the `Super + /` (or the key to the left of Right Shift) shortcut.

You can modify your keyboard language by editing the `~/.config/hypr/input.conf` file.

Wallpapers are changed randomly every 15 minutes. If you don't want that, in the `~/.config/hypr/startup.conf` file, comment or delete the line `exec-once = ~/.config/hypr/scripts/wallpaper.sh` and use a program like Waypaper to set the one you want.

You can modify your display settings using the nwg-displays app.

# Preview
![Preview](preview.png)