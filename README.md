
# How to use

In order to install my dotfiles, you first need to update your system:

    sudo dnf upgrade --refresh

If you're using nobara, use `nobara-sync` instead.
After that, you can now clone the repository:

    git clone https://github.com/Reyshyram/Dotfiles.git
Then, cd into the directory containing the dotfiles:

    cd Dotfiles
Finally, launch the install script:

    ./install.sh
If you're using Nobara, please also install Gnome Text Editor : `sudo dnf install gnome-text-editor`. The GTK theme will only work on system-wide flatpak installs.

The installation should now be completed. If there is any problem, feel free to open an issue.

## Compatibility
This script is only confirmed to be working under Nobara / Fedora 39 and Gnome 45, because it uses dnf in order to install the required packages.

# Preview
![Desktop](./preview.png)

# Shortcuts
|Action|Keybind|
|--|--|
| Exit an app | Super + Q|
| Resize a window | Super + Right Click|
| Move a window | Super + Left Click|
| Open the browser | Super + F |
| Open the file manager | Super + E |
| Open the terminal | Super + T |
| Open a notepad | Super + B |

# After installation
You can customize your wallpapers using the Hydrapaper app. You can also change devices' names in the Quick Settings panel by opening the Extensions app and modifying the settings of the Quick Settings Audio Devices Renamer extension. In this app, you can also customize the other extensions.
You may want to use the [Catppuccin for duckduckgo](https://github.com/catppuccin/duckduckgo) theme.

# Things used
 - [Bibata](https://github.com/ful1e5/Bibata_Cursor) cursor theme
 - [Nemo](https://github.com/linuxmint/nemo/) file manager
 - [File Roller](https://gitlab.gnome.org/GNOME/file-roller) archiver
 - [Zsh](https://www.zsh.org/) shell 
 - [Oh My Zsh](https://github.com/ohmyzsh/ohmyzsh) zsh plugin manager
 - [Zsh Autosuggestions](https://github.com/zsh-users/zsh-autosuggestions) plugin
 - [Zsh Syntax Highlighting](https://github.com/zsh-users/zsh-syntax-highlighting) plugin with [Catppuccin Mocha](https://github.com/catppuccin/zsh-syntax-highlighting) color scheme
 - [Kitty](https://github.com/kovidgoyal/kitty) terminal with [Catppuccin Mocha](https://github.com/catppuccin/kitty) color scheme
 - [Powerlevel10k](https://github.com/romkatv/powerlevel10k) zsh theme
 - [Amberol](https://gitlab.gnome.org/World/amberol) music player
 - [Catppuccin Mocha](https://github.com/catppuccin/grub) grub theme
 - A combination of [Catppuccin Mocha Standard Lavender Dark](https://github.com/catppuccin/gtk) gtk theme and the custom topbar of [ART3MISTICAL](https://github.com/ART3MISTICAL/dotfiles)
 - [MoreWaita](https://github.com/somepaulo/MoreWaita) icon theme
 - [Floorp](https://floorp.app/en/) browser
 - [Shina Fox](https://github.com/Shina-SG/Shina-Fox) floorp theme
