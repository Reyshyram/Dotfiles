#!/bin/bash

# Make dnf better
sudo cp config/dnf.conf /etc/dnf/dnf.conf

# Install required packages
sudo dnf copr enable peterwu/rendezvous
sudo dnf install git firefox nemo gnome-tweaks bibata-cursor-themes gnome-themes-extra file-roller qt5ct hydrapaper neofetch vlc zsh kitty
flatpak install flathub io.bassi.Amberol

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

# Nemo
gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings "['/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/']"
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/ name 'File Browser'
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/ command 'nemo'
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/ binding '<Super>e'

# Terminal
gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings "['/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/']"
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/ name 'Terminal'
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/ command 'kitty'
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/ binding '<Super>t'

# Text editor
gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings "['/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom3/']"
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom3/ name 'Text Editor'
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom3/ command 'gnome-text-editor'
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom3/ binding '<Super>b'

# Grub theme
git clone https://github.com/catppuccin/grub.git
mkdir -p /usr/share/grub/themes/
sudo cp -r grub/src/* /usr/share/grub/themes/
rm -rf grub
sudo cp config/grub /etc/default/grub
sudo grub2-mkconfig -o /boot/grub2/grub.cfg

# GTK Theme
wget https://github.com/catppuccin/gtk/releases/download/v0.7.1/Catppuccin-Mocha-Standard-Lavender-Dark.zip
file-roller --extract-here Catppuccin-Mocha-Standard-Lavender-Dark.zip 
rm Catppuccin-Mocha-Standard-Lavender-Dark.zip
mkdir -p ~/.themes
mv Catppuccin-Mocha-Standard-Lavender-Dark* ~/.themes
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

# Kitty as default
sudo mv /usr/bin/gnome-terminal /usr/bin/gnome-terminal.NOPE
sudo ln -sfv /usr/bin/kitty /usr/bin/gnome-terminal

# Zsh config
chsh -s $(which zsh)
sudo chsh -s $(which zsh)
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
mkdir -p ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting/themes
git clone https://github.com/catppuccin/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting/themes/catppuccin
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
wget https://raw.githubusercontent.com/romkatv/powerlevel10k-media/master/MesloLGS%20NF%20Regular.ttf
wget https://raw.githubusercontent.com/romkatv/powerlevel10k-media/master/MesloLGS%20NF%20Bold.ttf
wget https://raw.githubusercontent.com/romkatv/powerlevel10k-media/master/MesloLGS%20NF%20Italic.ttf
wget https://raw.githubusercontent.com/romkatv/powerlevel10k-media/master/MesloLGS%20NF%20Bold%20Italic.ttf
mv MesloLGS* /home/reyshyram/.local/share/fonts
cp config/.zshrc ~/.zshrc
cp config/.p10k.zsh ~/.p10k.zsh

# Kitty config
mkdir -p ~/.config/kitty
cp -r config/kitty/* ~/.config/kitty

echo "Please launch the extensions app and add User Themes, then add Catppuccinn as the shell theme"
echo "Please install extensions and configure them"
echo "Please set default apps"
