#!/bin/bash

echo "Installing Reyshyram's dotfiles..."

# Enable extra things for pacman
echo "Making pacman better..."
sudo sed -i "/^#Color/c\Color\nILoveCandy
    /^#VerbosePkgLists/c\VerbosePkgLists
    /^#ParallelDownloads/c\ParallelDownloads = 5" /etc/pacman.conf
sudo sed -i '/^#\[multilib\]/,+1 s/^#//' /etc/pacman.conf

# Install required packages
echo "Installing required packages..."
sudo pacman -S --needed --noconfirm git base-devel
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si
cd ..
rm -rf yay
sudo pacman -S --needed --noconfirm micro wl-clipboard os-prober kitty hyprland qt5-graphicaleffects qt5-quickcontrols2 qt5-svg noto-fonts fastfetch plymouth ttf-firacode-nerd zsh qt5-wayland qt6-wayland pipewire wireplumber xdg-desktop-portal-hyprland pacman-contrib btop nwg-look qt5ct qt6ct papirus-icon-theme kvantum sddm brightnessctl pamixer playerctl xdg-user-dirs sound-theme-freedesktop yad jq vlc gwenview tumbler ffmpegthumbnailer polkit-gnome udiskie grim socat pipewire wireplumber networkmanager pipewire-alsa pipewire-audio pipewire-jack pipewire-pulse gst-plugin-pipewire cliphist slurp swappy noto-fonts-emoji firewalld waybar xdg-desktop-portal-gtk bluez bluez-utils blueman network-manager-applet pavucontrol ttf-meslo-nerd gnome-keyring kooha kvantum-qt5 gnome-disk-utility firefox swaync hyprlock hypridle python-pipx pcmanfm-qt ark cpio meson cmake hyprwayland-scanner man libreoffice-fresh evince gnome-clocks rofi-wayland p7zip unrar swww imagemagick
yay -S --needed --noconfirm bibata-cursor-theme ttf-meslo-nerd-font-powerlevel10k visual-studio-code-bin g4music hardcode-fixer-git nwg-drawer-bin wlogout xwaylandvideobridge github-desktop-bin hyprpicker grimblast-git aurutils arch-update nwg-displays wlr-randr python-zombie-imp gradience adw-gtk-theme

# SDDM Configuration
echo "Preparing SDDM theme..."
systemctl enable sddm.service
sudo cp -r ./config/sddm/sugar-candy /usr/share/sddm/themes/
sudo cp ./config/sddm/sddm.conf /etc/sddm.conf
sudo chown $USER /usr/share/sddm/themes/sugar-candy/Backgrounds/cache.png

# Grub theme and configuration
echo "Preparing grub theme..."
git clone https://github.com/Coopydood/HyperFluent-GRUB-Theme.git
sudo mkdir -p /usr/share/grub/themes/
sudo cp -r ./HyperFluent-GRUB-Theme/arch /usr/share/grub/themes/
rm -rf ./HyperFluent-GRUB-Theme
sudo sed -i 's/^#GRUB_DISABLE_OS_PROBER=false/GRUB_DISABLE_OS_PROBER=false/' /etc/default/grub
sudo sed -i 's|^#GRUB_THEME="/path/to/gfxtheme"|GRUB_THEME="/usr/share/grub/themes/arch/theme.txt"|' /etc/default/grub
sudo sed -i 's/^GRUB_DEFAULT=.*/GRUB_DEFAULT=saved/; s/^#GRUB_SAVEDEFAULT=true/GRUB_SAVEDEFAULT=true/' /etc/default/grub
sudo grub-mkconfig -o /boot/grub/grub.cfg

# Kitty configuration
echo "Preparing kitty configuration..."
mkdir -p ~/.config/kitty
cp -r ./config/kitty/* ~/.config/kitty

# Zsh configuration
echo "Preparing zsh configuration..."
chsh -s $(which zsh)
sudo chsh -s $(which zsh)
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
mkdir -p ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting/themes
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
cp ./config/.zshrc ~/.zshrc
cp ./config/.zprofile ~/.zprofile
cp ./config/.p10k.zsh ~/.p10k.zsh
cp ./config/autosuggestions.zsh ~/.oh-my-zsh/custom/autosuggestions.zsh
fc-cache

# Micro theme configuration
echo "Preparing micro theme..."
git clone https://github.com/catppuccin/micro.git
mkdir -p ~/.config/micro/colorschemes
cp -r ./micro/src/* ~/.config/micro/colorschemes
rm -rf ./micro
sed -i '1d' ~/.config/micro/colorschemes/catppuccin-mocha.micro
cp ./config/micro/settings.json ~/.config/micro/settings.json

# Plymouth theme
echo "Preparing plymouth theme..."
sudo sed -i 's/^GRUB_CMDLINE_LINUX_DEFAULT=.*/GRUB_CMDLINE_LINUX_DEFAULT="quiet splash loglevel=3 systemd.show_status=auto rd.udev.log_level=3"/' /etc/default/grub
sudo sed -i '/^\[Daemon\]/a ShowDelay=0' /etc/plymouth/plymouthd.conf
sudo sed -i '/^HOOKS=/ s/)$/ plymouth)/' /etc/mkinitcpio.conf
sudo grub-mkconfig -o /boot/grub/grub.cfg
sudo cp -r ./config/plymouth/black_hud /usr/share/plymouth/themes/
sudo plymouth-set-default-theme -R black_hud

# Btop theme
echo "Preparing btop theme..."
cp -r ./config/btop/* ~/.config/btop/

# Swaync config
echo "Applying swaync config..."
mkdir -p ~/.config/swaync
cp -r ./config/swaync/* ~/.config/swaync/

# Copy Hyprland config
echo "Copying Hyprland config..."
mkdir -p ~/.config/hypr
cp -r ./config/hypr/* ~/.config/hypr/
chmod +x ~/.config/hypr/scripts/dontkillsteam.sh
chmod +x ~/.config/hypr/scripts/sounds.sh
chmod +x ~/.config/hypr/scripts/media.sh
chmod +x ~/.config/hypr/scripts/volume.sh
chmod +x ~/.config/hypr/scripts/brightness.sh
chmod +x ~/.config/hypr/scripts/keybinds_help.sh
chmod +x ~/.config/hypr/scripts/logoutmenu.sh
chmod +x ~/.config/hypr/scripts/wallpaper.sh
chmod +x ~/.config/hypr/scripts/random-wallpaper.sh
chmod +x ~/.config/hypr/scripts/clipboard.sh
chmod +x ~/.config/hypr/scripts/emoji.sh
chmod +x ~/.config/hypr/scripts/desktop-portal.sh

mkdir -p ~/.config/wal/templates
cp -r ./config/pywal/* ~/.config/wal/templates

# Plugins
hyprpm update
hyprpm add https://github.com/KZDKM/Hyprspace
hyprpm enable Hyprspace

# Applications Associations
xdg-settings set default-web-browser firefox.desktop
xdg-mime default pcmanfm-qt.desktop inode/directory

# Papyrus icon theme
echo "Applying icon theme..."
sudo hardcode-fixer
papirus-folders -C cat-mocha-lavender

# Gtk theme
echo "Applying Gtk theme..."
mkdir -p ~/.config/gtk-4.0
mkdir -p ~/.config/gtk-3.0
cp -r ./config/gtk-* ~/.config/
cp -r ./config/nwg-look ~/.config/
cp -r ./config/xsettingsd ~/.config/
cp ./config/.gtkrc-2.0 ~/.gtkrc-2.0

# QT theme
echo "Applying Qt theme..."
cp -r ./config/qt* ~/.config/
cp -r ./config/Kvantum ~/.config/

# Rofi Config
echo "Applying rofi theme..."
cp -r ./config/rofi ~/.config/

# Nwg-drawer config
echo "Applying nwg-drawer theme..."
cp -r ./config/nwg-drawer ~/.config/

# Logout menu
echo "Applying wlogout config..."
cp -r ./config/wlogout ~/.config/

# Auto cpu frequency
echo "Installing auto-cpufreq, please select install..."
git clone https://github.com/AdnanHodzic/auto-cpufreq.git
cd auto-cpufreq && sudo ./auto-cpufreq-installer
cd ..
rm -rf ./auto-cpufreq/
sudo auto-cpufreq --install

# Copy wallpapers
echo "Copying wallpapers..."
mkdir -p ~/Pictures/Wallpapers
mkdir -p ~/Pictures/Screenshots
cp -r ./Wallpapers/* ~/Pictures/Wallpapers

# Enable firewalld
echo "Enabling firewalld..."
systemctl enable firewalld.service

# Adding user to input group
echo "Adding user to input group..."
sudo usermod -a -G input $USER

# Enabling bluetooth
echo "Enabling bluetooth..."
systemctl enable bluetooth.service

# Copying waybar config
echo "Copying waybar configuration..."
cp -r ./config/waybar ~/.config/
chmod +x ~/.config/waybar/scripts/checkupdates.sh

# Pcmanfm-qt
echo "Applying pcmanfm-qt configuration..."
cp -r ./config/pcmanfm-qt ~/.config/

# Fastfetch
echo "Copying fastfetch theme..."
cp -r ./config/fastfetch ~/.config/

# Swappy
echo "Copying swappy config..."
cp -r ./config/swappy ~/.config/

# Pywal setup
pipx install pywal16
pipx ensurepath

mkdir -p ~/.config/wal/templates
cp -r ./pywal16-libadwaita/templates/* ~/.config/wal/templates
 
./pywal16-libadwaita/scripts/apply-theme.sh

~/.local/bin/wal --cols16 -i ~/Pictures/Wallpapers/celeste.png -n
gradience-cli apply -n "pywal" --gtk both