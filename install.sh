#!/bin/bash

# Make dnf better
sudo cp ./config/dnf.conf /etc/dnf/dnf.conf

# Install required packages
sudo dnf copr enable peterwu/rendezvous
sudo dnf copr enable dusansimic/themes
sudo dnf install git firefox nemo gnome-tweaks bibata-cursor-themes gnome-themes-extra file-roller hydrapaper neofetch vlc zsh kitty pipx morewaita-icon-theme
flatpak install flathub io.bassi.Amberol
flatpak install flathub org.gnome.Extensions
flatpak install flathub one.ablaze.floorp

# Setting up gnome settings
gsettings set org.gnome.desktop.interface icon-theme 'MoreWaita' # Icon Theme
sudo gtk-update-icon-cache -f -t /usr/share/icons/MoreWaita && xdg-desktop-menu forceupdate # Reload icon theme
gsettings set org.gnome.desktop.interface cursor-theme 'Bibata-Modern-Classic' # Cursor
gsettings set org.gnome.desktop.interface enable-hot-corners false # Disable hot corner
gsettings set org.gnome.mutter workspaces-only-on-primary false # Enable workspaces on all monitors
gsettings set org.gnome.settings-daemon.plugins.power power-button-action 'interactive' # Power button will shut down the computer
gsettings set org.gnome.desktop.peripherals.mouse accel-profile 'flat' # Enable raw input
gsettings set org.gnome.desktop.wm.keybindings close "['<Alt>F4', '<Super>q']" # Close window with Super + q
gsettings set org.gnome.desktop.wm.keybindings toggle-fullscreen "['F11']" # Fullscreen with F11
gsettings set org.gnome.desktop.wm.preferences button-layout 'appmenu:minimize,maximize,close' # Show minimize and maximize buttons
gsettings set org.gnome.desktop.wm.preferences resize-with-right-button true # Move window with Super + Right Click
dconf write /org/gnome/mutter/center-new-windows true # Center new windows
gsettings set org.gnome.desktop.peripherals.touchpad tap-to-click true # Touchpad tap to click

# Custom shortcuts
gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings "['/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/', '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/', '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/', '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom3/']"

# Floorp
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ name 'Browser'
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ command 'flatpak run one.ablaze.floorp'
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
sudo cp -r ./grub/src/* /usr/share/grub/themes/
rm -rf ./grub
sudo cp ./config/grub /etc/default/grub
sudo grub2-mkconfig -o /boot/grub2/grub.cfg

# GTK Theme
wget https://github.com/catppuccin/gtk/releases/download/v0.7.1/Catppuccin-Mocha-Standard-Lavender-Dark.zip
file-roller --extract-here ./Catppuccin-Mocha-Standard-Lavender-Dark.zip 
rm ./Catppuccin-Mocha-Standard-Lavender-Dark.zip
mkdir -p ~/.themes
mv ./Catppuccin-Mocha-Standard-Lavender-Dark/* ~/.themes
rm -r ./Catppuccin-Mocha-Standard-Lavender-Dark
gsettings set org.gnome.desktop.interface gtk-theme 'Catppuccin-Mocha-Standard-Lavender-Dark'
mkdir -p ~/.config/gtk-4.0
ln -sf ~/.themes/Catppuccin-Mocha-Standard-Lavender-Dark/gtk-4.0/assets ~/.config/gtk-4.0/assets
ln -sf ~/.themes/Catppuccin-Mocha-Standard-Lavender-Dark/gtk-4.0/gtk.css ~/.config/gtk-4.0/gtk.css
ln -sf ~/.themes/Catppuccin-Mocha-Standard-Lavender-Dark/gtk-4.0/gtk-dark.css ~/.config/gtk-4.0/gtk-dark.css
sudo flatpak override --filesystem=$HOME/.themes
sudo flatpak override --filesystem=/usr/share/icons
sudo flatpak override --env=GTK_THEME=Catppuccin-Mocha-Standard-Lavender-Dark
sudo flatpak override --env=ICON_THEME=MoreWaita
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
mv ./MesloLGS* ~/.local/share/fonts
cp ./config/.zshrc ~/.zshrc
cp ./config/.p10k.zsh ~/.p10k.zsh
cp ./config/autosuggestions.zsh ~/.oh-my-zsh/custom/autosuggestions.zsh

# Kitty config
sudo mv /usr/bin/gnome-terminal /usr/bin/gnome-terminal.NOPE
sudo ln -sfv /usr/bin/kitty /usr/bin/gnome-terminal
mkdir -p ~/.config/kitty
cp -r ./config/kitty/* ~/.config/kitty

# Wallpaper
hydrapaper -c ./Wallpapers/zero-two-and-hiro.jpg ./Wallpapers/zero-two-and-hiro.jpg ./Wallpapers/zero-two-and-hiro.jpg ./Wallpapers/zero-two-and-hiro.jpg ./Wallpapers/zero-two-and-hiro.jpg

# Set default apps
cp ./config/mimeapps.list ~/.config/mimeapps.list

# Media Codecs
sudo dnf install gstreamer1-plugins-{bad-\*,good-\*,base} gstreamer1-plugin-openh264 gstreamer1-plugin-libav --exclude=gstreamer1-plugins-bad-free-devel
sudo dnf install lame\* --exclude=lame-devel
sudo dnf group upgrade --with-optional Multimedia

# Configure Gnome Extensions
pipx ensurepath
pipx install gnome-extensions-cli --system-site-packages

~/.local/share/pipx/venvs/gnome-extensions-cli/bin/gnome-extensions-cli install user-theme@gnome-shell-extensions.gcampax.github.com
~/.local/share/pipx/venvs/gnome-extensions-cli/bin/gnome-extensions-cli install appindicatorsupport@rgcjonas.gmail.com
~/.local/share/pipx/venvs/gnome-extensions-cli/bin/gnome-extensions-cli install update-extension@purejava.org
~/.local/share/pipx/venvs/gnome-extensions-cli/bin/gnome-extensions-cli install clipboard-history@alexsaveau.dev
~/.local/share/pipx/venvs/gnome-extensions-cli/bin/gnome-extensions-cli install color-picker@tuberry
~/.local/share/pipx/venvs/gnome-extensions-cli/bin/gnome-extensions-cli install just-perfection-desktop@just-perfection
~/.local/share/pipx/venvs/gnome-extensions-cli/bin/gnome-extensions-cli install quick-settings-tweaks@qwreey
~/.local/share/pipx/venvs/gnome-extensions-cli/bin/gnome-extensions-cli install tiling-assistant@leleat-on-github
~/.local/share/pipx/venvs/gnome-extensions-cli/bin/gnome-extensions-cli install dash-to-dock@micxgx.gmail.com
~/.local/share/pipx/venvs/gnome-extensions-cli/bin/gnome-extensions-cli install blur-my-shell@aunetx
~/.local/share/pipx/venvs/gnome-extensions-cli/bin/gnome-extensions-cli install quicksettings-audio-devices-renamer@marcinjahn.com
~/.local/share/pipx/venvs/gnome-extensions-cli/bin/gnome-extensions-cli install mediacontrols@cliffniff.github.com
~/.local/share/pipx/venvs/gnome-extensions-cli/bin/gnome-extensions-cli install applications-overview-tooltip@RaphaelRochet
~/.local/share/pipx/venvs/gnome-extensions-cli/bin/gnome-extensions-cli install steal-my-focus-window@steal-my-focus-window

dconf load /org/gnome/shell/extensions/ < ./config/extension-settings.dconf

~/.local/share/pipx/venvs/gnome-extensions-cli/bin/gnome-extensions-cli enable user-theme@gnome-shell-extensions.gcampax.github.com
~/.local/share/pipx/venvs/gnome-extensions-cli/bin/gnome-extensions-cli enable appindicatorsupport@rgcjonas.gmail.com
~/.local/share/pipx/venvs/gnome-extensions-cli/bin/gnome-extensions-cli enable update-extension@purejava.org
~/.local/share/pipx/venvs/gnome-extensions-cli/bin/gnome-extensions-cli enable clipboard-history@alexsaveau.dev
~/.local/share/pipx/venvs/gnome-extensions-cli/bin/gnome-extensions-cli enable color-picker@tuberry
~/.local/share/pipx/venvs/gnome-extensions-cli/bin/gnome-extensions-cli enable just-perfection-desktop@just-perfection
~/.local/share/pipx/venvs/gnome-extensions-cli/bin/gnome-extensions-cli enable quick-settings-tweaks@qwreey
~/.local/share/pipx/venvs/gnome-extensions-cli/bin/gnome-extensions-cli enable tiling-assistant@leleat-on-github
~/.local/share/pipx/venvs/gnome-extensions-cli/bin/gnome-extensions-cli enable dash-to-dock@micxgx.gmail.com
~/.local/share/pipx/venvs/gnome-extensions-cli/bin/gnome-extensions-cli enable blur-my-shell@aunetx
~/.local/share/pipx/venvs/gnome-extensions-cli/bin/gnome-extensions-cli enable quicksettings-audio-devices-renamer@marcinjahn.com
~/.local/share/pipx/venvs/gnome-extensions-cli/bin/gnome-extensions-cli enable mediacontrols@cliffniff.github.com
~/.local/share/pipx/venvs/gnome-extensions-cli/bin/gnome-extensions-cli enable applications-overview-tooltip@RaphaelRochet
~/.local/share/pipx/venvs/gnome-extensions-cli/bin/gnome-extensions-cli enable steal-my-focus-window@steal-my-focus-window

# Auto cpu frequency
git clone https://github.com/AdnanHodzic/auto-cpufreq.git
cd auto-cpufreq && sudo ./auto-cpufreq-installer
cd ..
 rm -rf ./auto-cpufreq/
 sudo auto-cpufreq --install
