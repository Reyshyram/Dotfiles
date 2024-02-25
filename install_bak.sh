sudo dnf install git firefox nemo gnome-tweaks bibata-cursor-themes gnome-themes-extra file-roller hydrapaper neofetch vlc zsh kitty pipx morewaita-icon-theme plymouth

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

# Load nemo config
dconf load /org/nemo/ < ./config/nemo.dconf

# Auto cpu frequency
git clone https://github.com/AdnanHodzic/auto-cpufreq.git
cd auto-cpufreq && sudo ./auto-cpufreq-installer
cd ..
rm -rf ./auto-cpufreq/
sudo auto-cpufreq --install
