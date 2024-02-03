#!/bin/bash

# Install required packages
sudo dnf copr enable peterwu/rendezvous
sudo dnf install git firefox pcmanfm gnome-tweaks bibata-cursor-themes gnome-themes-extra ark qt5ct hydrapaper

# Setting up gnome settings
gsettings set org.gnome.desktop.interface cursor-theme 'Bibata-Modern-Classic' # Cursor theme
gsettings set org.gnome.desktop.interface enable-hot-corners false
gsettings set org.gnome.mutter workspaces-only-on-primary false
gsettings set org.gnome.settings-daemon.plugins.power power-button-action 'interactive'
gsettings set org.gnome.desktop.peripherals.mouse accel-profile 'flat'
gsettings set org.gnome.desktop.wm.keybindings close "['<Alt>F4', '<Super>q']"
gsettings set org.gnome.desktop.wm.keybindings toggle-fullscreen "['F11']"
gsettings set org.gnome.desktop.wm.preferences button-layout 'appmenu:minimize,close'
gsettings set org.gnome.desktop.wm.preferences resize-with-right-button true

# Custom shortcuts
# Firefox
gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings "['/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/']"
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ name 'Browser'
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ command 'firefox'
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ binding '<Super>f'

# Pcmanfm
gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings "['/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/']"
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/ name 'File Browser'
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/ command 'pcmanfm'
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/ binding '<Super>e'

# Kitty
gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings "['/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/']"
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/ name 'Terminal'
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/ command 'gnome-terminal'
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/ binding '<Super>t'

# Grub theme
git clone https://github.com/catppuccin/grub.git
sudo cp -r grub/src/* /usr/share/grub/themes/
rm -rf grub
sudo cp config/grub /etc/default/grub
sudo grub2-mkconfig -o /boot/grub2/grub.cfg

# GTK Theme
wget https://github.com/catppuccin/gtk/releases/download/v0.7.1/Catppuccin-Mocha-Standard-Lavender-Dark.zip
ark -b -a Catppuccin-Mocha-Standard-Lavender-Dark.zip 
rm Catppuccin-Mocha-Standard-Lavender-Dark.zip
mkdir -p ~/.themes
mv Catppuccin-Mocha-Standard-Lavender-Dark/* ~/.themes
rm -r Catppuccin-Mocha-Standard-Lavender-Dark
gsettings set org.gnome.desktop.interface gtk-theme 'Catppuccin-Mocha-Standard-Lavender-Dark'
mkdir -p ~/.config/gtk-4.0
ln -sf ~/.themes/Catppuccin-Mocha-Standard-Lavender-Dark/gtk-4.0/assets ~/.config/gtk-4.0/assets
ln -sf ~/.themes/Catppuccin-Mocha-Standard-Lavender-Dark/gtk-4.0/gtk.css ~/.config/gtk-4.0/gtk.css
ln -sf ~/.themes/Catppuccin-Mocha-Standard-Lavender-Dark/gtk-4.0/gtk-dark.css ~/.config/gtk-4.0/gtk-dark.css
sudo flatpak override --filesystem=$HOME/.themes
sudo flatpak override --env=GTK_THEME=Catppuccin-Mocha-Standard-Lavender-Dark
flatpak install flathub org.gnome.Extensions
rm ~/.themes/Catppuccin-Mocha-Standard-Lavender-Dark/gnome-shell/gnome-shell.css
cp config/gnome-shell.css ~/.themes/Catppuccin-Mocha-Standard-Lavender-Dark/gnome-shell/gnome-shell.css

# Gnome terminal theme
curl -L https://raw.githubusercontent.com/catppuccin/gnome-terminal/v0.2.0/install.py | python3 -


xdg-mime default pcmanfm.desktop inode/directory application/x-gnome-saved-search

echo "Please launch the extensions app and add User Themes, then add Catppuccinn as the shell theme"
echo "Please launch the Gnome Terminal and enable Catppuccinn as the theme"
