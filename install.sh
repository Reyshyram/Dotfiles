#!/bin/bash

# Make dnf better
sudo cp config/dnf.conf /etc/dnf/dnf.conf

# Install required packages
sudo dnf copr enable peterwu/rendezvous
sudo dnf install git firefox nemo gnome-tweaks bibata-cursor-themes gnome-themes-extra file-roller qt5ct hydrapaper neofetch vlc zsh kitty
flatpak install flathub io.bassi.Amberol

# Setting up gnome settings
gsettings set org.gnome.desktop.interface cursor-theme 'Bibata-Modern-Classic' # Cursor
gsettings set org.gnome.desktop.interface enable-hot-corners false # Disable hot corner
gsettings set org.gnome.mutter workspaces-only-on-primary false # Enable workspaces on all monitors
gsettings set org.gnome.settings-daemon.plugins.power power-button-action 'interactive' # Power button will shut down the computer
gsettings set org.gnome.desktop.peripherals.mouse accel-profile 'flat' # Enable raw input
gsettings set org.gnome.desktop.wm.keybindings close "['<Alt>F4', '<Super>q']" # Close window with Super + q
gsettings set org.gnome.desktop.wm.keybindings toggle-fullscreen "['F11']" # Fullscreen with F11
gsettings set org.gnome.desktop.wm.preferences button-layout 'appmenu:minimize,close' # Show minimize and maximize buttons
gsettings set org.gnome.desktop.wm.preferences resize-with-right-button true # Move window with Super + Right Click

# Custom shortcuts
gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings "['/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/', '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/', '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/', '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom3/']"

# Firefox
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ name 'Browser'
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ command 'firefox'
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ binding '<Super>f'

# Nemo
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/ name 'File Browser'
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/ command 'nemo'
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/ binding '<Super>e'

# Kitty
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/ name 'Terminal'
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/ command 'kitty'
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/ binding '<Super>t'

# Text editor
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom3/ name 'Text Editor'
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom3/ command 'gnome-text-editor'
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom3/ binding '<Super>b'

# Grub theme
git clone https://github.com/catppuccin/grub.git
sudo mkdir -p /usr/share/grub/themes/
sudo cp -r grub/src/* /usr/share/grub/themes/
rm -rf grub
sudo cp config/grub /etc/default/grub
sudo grub2-mkconfig -o /boot/grub2/grub.cfg

# GTK Theme
wget https://github.com/catppuccin/gtk/releases/download/v0.7.1/Catppuccin-Mocha-Standard-Lavender-Dark.zip
file-roller --extract-here Catppuccin-Mocha-Standard-Lavender-Dark.zip 
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

# Set nemo as default
xdg-mime default nemo.desktop inode/directory application/x-gnome-saved-search

# Zsh config
chsh -s $(which zsh)
sudo chsh -s $(which zsh)
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
mkdir -p ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting/themes
git clone https://github.com/catppuccin/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting/themes/catppuccin
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
wget https://raw.githubusercontent.com/romkatv/powerlevel10k-media/master/MesloLGS%20NF%20Regular.ttf
wget https://raw.githubusercontent.com/romkatv/powerlevel10k-media/master/MesloLGS%20NF%20Bold.ttf
wget https://raw.githubusercontent.com/romkatv/powerlevel10k-media/master/MesloLGS%20NF%20Italic.ttf
wget https://raw.githubusercontent.com/romkatv/powerlevel10k-media/master/MesloLGS%20NF%20Bold%20Italic.ttf
mkdir -p ~/.local/share/fonts
mv MesloLGS* ~/.local/share/fonts
cp config/.zshrc ~/.zshrc
cp config/.p10k.zsh ~/.p10k.zsh

# Kitty config
sudo mv /usr/bin/gnome-terminal /usr/bin/gnome-terminal.NOPE
sudo ln -sfv /usr/bin/kitty /usr/bin/gnome-terminal
mkdir -p ~/.config/kitty
cp -r config/kitty/* ~/.config/kitty

# Wallpaper
hydrapaper -c Wallpapers/zero-two-and-hiro.jpg Wallpapers/zero-two-and-hiro.jpg Wallpapers/zero-two-and-hiro.jpg Wallpapers/zero-two-and-hiro.jpg Wallpapers/zero-two-and-hiro.jpg
