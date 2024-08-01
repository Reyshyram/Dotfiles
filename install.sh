#!/bin/bash

# Function to ask yes or no questions
ask_yes_no() {
    while true; do
        read -p "$1 (Yy/Nn): " response
        case $response in
            [Yy]* ) return 0;;
            [Nn]* ) return 1;;
            * ) echo "Please answer with y or n.";;
        esac
    done
}

# Function to check and enable multilib repository
enable_multilib() {
    if ! grep -q "^\[multilib\]" /etc/pacman.conf; then
        echo "Enabling multilib repository..."
        sudo tee -a /etc/pacman.conf > /dev/null <<EOT

[multilib]
Include = /etc/pacman.d/mirrorlist
EOT
        echo "Multilib repository has been enabled."
    else
        echo "Multilib repository is already enabled."
    fi
}

# Function to install yay
install_yay() {
    if ! command -v yay &> /dev/null; then
        echo "Installing yay..."
        sudo pacman -S --needed --noconfirm git base-devel
        git clone https://aur.archlinux.org/yay-bin.git
        cd yay-bin || exit
        makepkg -si --noconfirm
        cd .. && rm -rf yay-bin
        export PATH="$PATH:$HOME/.local/bin"
    else
        echo "yay is already installed."
    fi
}

# Function to install AMD GPU drivers and tools
install_amd() {
    echo "Installing AMD GPU drivers and tools..."
    sudo pacman -S --needed mesa lib32-mesa vulkan-radeon lib32-vulkan-radeon vulkan-icd-loader lib32-vulkan-icd-loader
    yay -S lact
}

# Function to install Nvidia GPU drivers and tools
install_nvidia() {
    echo "Installing Nvidia GPU drivers and tools..."
    sudo pacman -S --needed nvidia-dkms nvidia-utils lib32-nvidia-utils nvidia-settings opencl-nvidia egl-wayland libva-nvidia-driver
    
    echo "Editing /etc/mkinitcpio.conf to add Nvidia modules..."
    sudo sed -i 's/^MODULES=(/&nvidia nvidia_modeset nvidia_uvm nvidia_drm /' /etc/mkinitcpio.conf

    echo "Creating and editing /etc/modprobe.d/nvidia.conf..."
    echo "options nvidia_drm modeset=1 fbdev=1" | sudo tee /etc/modprobe.d/nvidia.conf

    echo "Rebuilding the initramfs..."
    sudo mkinitcpio -P

    echo "Adding environment variables to ~/.config/hypr/env_variables.conf..."
    mkdir -p ~/.config/hypr
    cat <<EOL >> ~/.config/hypr/env_variables.conf
env = LIBVA_DRIVER_NAME,nvidia
env = GBM_BACKEND,nvidia_drm
env = __GLX_VENDOR_LIBRARY_NAME,nvidia
env = NVD_BACKEND,direct

cursor {
    no_hardware_cursors = true
}
EOL

    echo "Enabling required services..."
    sudo systemctl enable nvidia-suspend.service
    sudo systemctl enable nvidia-hibernate.service
    sudo systemctl enable nvidia-resume.service

    echo "Adding kernel parameter to GRUB..."
    sudo sed -i 's/^\(GRUB_CMDLINE_LINUX_DEFAULT="[^"]*\)/\1 nvidia.NVreg_PreserveVideoMemoryAllocations=1/' /etc/default/grub
    sudo grub-mkconfig -o /boot/grub/grub.cfg
}

# Packages to install
PACKAGES=(
    micro wl-clipboard os-prober kitty hyprland qt5-graphicaleffects
    qt5-quickcontrols2 qt5-svg noto-fonts noto-fonts-cjk fastfetch plymouth
    ttf-firacode-nerd zsh qt5-wayland qt6-wayland pipewire wireplumber
    xdg-desktop-portal-hyprland pacman-contrib btop nwg-look qt5ct qt6ct
    papirus-icon-theme kvantum sddm brightnessctl pamixer playerctl
    xdg-user-dirs sound-theme-freedesktop yad jq vlc gwenview tumbler
    ffmpegthumbnailer polkit-gnome udiskie grim socat pipewire wireplumber
    networkmanager pipewire-alsa pipewire-audio pipewire-jack pipewire-pulse
    gst-plugin-pipewire cliphist slurp noto-fonts-emoji firewalld
    waybar xdg-desktop-portal-gtk bluez bluez-utils blueman
    network-manager-applet pavucontrol ttf-meslo-nerd gnome-keyring kooha
    kvantum-qt5 gnome-disk-utility firefox swaync hyprlock hypridle
    python-pipx pcmanfm-qt ark cpio meson cmake hyprwayland-scanner man
    libreoffice-fresh evince gnome-clocks p7zip unrar swww imagemagick
    gstreamer gst-plugins-bad gst-plugins-base gst-plugins-good
    gst-plugins-ugly pkgconf pinta vim fzf reflector zoxide wget
    zenity baobab gnome-font-viewer unzip
)

# AUR packages to install
YAY_PACKAGES=(
    bibata-cursor-theme visual-studio-code-bin g4music hardcode-fixer-git
    nwg-drawer-bin wlogout xwaylandvideobridge github-desktop-bin
    hyprpicker grimblast-git aurutils arch-update nwg-displays
    wlr-randr python-zombie-imp gradience adw-gtk-theme pywal-16-colors
    smile clipse swayosd-git ttf-meslo-nerd-font-powerlevel10k
    apple-fonts
)

# Gaming packages to install
GAMING_PACKAGES=(
    steam lutris wine-staging winetricks gamemode lib32-gamemode
    giflib lib32-giflib libpng lib32-libpng libldap lib32-libldap
    gnutls lib32-gnutls mpg123 lib32-mpg123 openal lib32-openal
    v4l-utils lib32-v4l-utils libpulse lib32-libpulse libgpg-error lib32-libgpg-error
    alsa-plugins lib32-alsa-plugins alsa-lib lib32-alsa-lib
    libjpeg-turbo lib32-libjpeg-turbo sqlite lib32-sqlite libxcomposite lib32-libxcomposite
    libxinerama lib32-libxinerama ncurses lib32-ncurses opencl-icd-loader lib32-opencl-icd-loader
    libxslt lib32-libxslt libva lib32-libva gtk3 lib32-gtk3
    gst-plugins-base-libs lib32-gst-plugins-base-libs vulkan-icd-loader lib32-vulkan-icd-loader
    mangohud lib32-mangohud goverlay gamescope
)

# AUR gaming packages to install
GAMING_PACKAGES_YAY=(
    vkbasalt lib32-vkbasalt proton-ge-custom-bin dxvk-bin vesktop-bin protontricks
)

echo "Installing Reyshyram's dotfiles..."

# Enhance pacman
echo "Configuring pacman..."
sudo sed -i 's/^#Color/Color/; s/^#VerbosePkgLists/VerbosePkgLists/; s/^#ParallelDownloads/ParallelDownloads = 5/' /etc/pacman.conf
enable_multilib

# Install yay
install_yay

# Enable TRIM for SSDs
sudo systemctl enable fstrim.timer

# Install additional packages
echo "Installing required packages..."
sudo pacman -S --needed "${PACKAGES[@]}"
yay -S --needed "${YAY_PACKAGES[@]}"

# Configure SDDM
echo "Configuring SDDM..."
sudo cp -r ./config/sddm/sugar-candy /usr/share/sddm/themes/
sudo cp ./config/sddm/sddm.conf /etc/sddm.conf
sudo chown "$USER" /usr/share/sddm/themes/sugar-candy/Backgrounds/cache.png
systemctl enable sddm.service

# Configure GRUB
echo "Configuring GRUB..."
git clone https://github.com/Coopydood/HyperFluent-GRUB-Theme.git
sudo mkdir -p /usr/share/grub/themes/
sudo cp -r ./HyperFluent-GRUB-Theme/arch /usr/share/grub/themes/
rm -rf ./HyperFluent-GRUB-Theme
sudo sed -i 's/^#GRUB_DISABLE_OS_PROBER=false/GRUB_DISABLE_OS_PROBER=false/' /etc/default/grub
sudo sed -i 's|^#GRUB_THEME="/path/to/gfxtheme"|GRUB_THEME="/usr/share/grub/themes/arch/theme.txt"|' /etc/default/grub
sudo sed -i 's/^GRUB_DEFAULT=.*/GRUB_DEFAULT=saved/; s/^#GRUB_SAVEDEFAULT=true/GRUB_SAVEDEFAULT=true/' /etc/default/grub
sudo grub-mkconfig -o /boot/grub/grub.cfg

# Configure Kitty
echo "Configuring Kitty..."
mkdir -p ~/.config/kitty
cp -r ./config/kitty/* ~/.config/kitty

# Configure Zsh
echo "Configuring Zsh..."
chsh -s "$(which zsh)"
sudo chsh -s "$(which zsh)"
curl -s https://ohmyposh.dev/install.sh | bash -s
cp ./config/.zshrc ~/.zshrc
cp ./config/.zprofile ~/.zprofile
mkdir -p ~/.config/oh-my-posh
cp ./config/reyshi-prompt.omp.json ~/.config/oh-my-posh/reyshi-prompt.omp.json
fc-cache

# Configure Micro theme
echo "Configuring Micro theme..."
mkdir -p ~/.config/micro/
cp ./config/micro/settings.json ~/.config/micro/settings.json

# Configure Plymouth
echo "Configuring Plymouth..."
sudo sed -i 's/^GRUB_CMDLINE_LINUX_DEFAULT=.*/GRUB_CMDLINE_LINUX_DEFAULT="quiet splash loglevel=3 systemd.show_status=auto rd.udev.log_level=3"/' /etc/default/grub
sudo sed -i '/^\[Daemon\]/a ShowDelay=0' /etc/plymouth/plymouthd.conf
sudo sed -i '/^HOOKS=/ s/)$/ plymouth)/' /etc/mkinitcpio.conf
sudo grub-mkconfig -o /boot/grub/grub.cfg
sudo cp -r ./config/plymouth/black_hud /usr/share/plymouth/themes/
sudo plymouth-set-default-theme -R black_hud

# Configure Btop
echo "Configuring Btop..."
cp -r ./config/btop/* ~/.config/btop/

# Configure Swaync
echo "Configuring Swaync..."
mkdir -p ~/.config/swaync
cp -r ./config/swaync/* ~/.config/swaync/
sed -i "s|/home/reyshyram|$HOME|g" ~/.config/swaync/config.json
chmod +x ~/.config/swaync/notification-controller.sh

# Enable SwayOSD backend
echo "Enabling SwayOSD backend..."
sudo systemctl enable --now swayosd-libinput-backend.service

# Configure Hyprland
echo "Configuring Hyprland..."
mkdir -p ~/.config/hypr
cp -r ./config/hypr/* ~/.config/hypr/
chmod +x ~/.config/hypr/scripts/*.sh
# Disable plugin keybind while not installed
sed -i 's/^bind = $mainMod, Tab, overview:toggle, all/#&/' ~/.config/hypr/keybinds.conf
# Send notification post install when restarting
echo "exec-once = ~/.config/hypr/scripts/post_install_listener" >> ~/.config/hypr/startup.conf

# Configure Pywal templates
mkdir -p ~/.config/wal/templates
cp -r ./config/pywal/* ~/.config/wal/templates

# Set application associations
xdg-settings set default-web-browser firefox.desktop
xdg-mime default pcmanfm-qt.desktop inode/directory

# Apply Papirus icon theme
echo "Applying icon theme..."
sudo hardcode-fixer
papirus-folders -C cat-mocha-lavender

# Apply GTK theme
echo "Applying GTK theme..."
mkdir -p ~/.config/gtk-3.0 ~/.config/gtk-4.0
cp -r ./config/gtk-* ~/.config/
cp -r ./config/nwg-look ~/.config/
cp -r ./config/xsettingsd ~/.config/
cp ./config/.gtkrc-2.0 ~/

# Apply QT theme
echo "Applying QT theme..."
cp -r ./config/qt* ~/.config/
cp -r ./config/Kvantum ~/.config/

# Configure Nwg-drawer
echo "Configuring Nwg-drawer..."
cp -r ./config/nwg-drawer ~/.config/

# Configure Wlogout
echo "Configuring Wlogout..."
cp -r ./config/wlogout ~/.config/

# Install and configure auto-cpufreq
echo "Installing auto-cpufreq..."
git clone https://github.com/AdnanHodzic/auto-cpufreq.git
cd auto-cpufreq
sudo ./auto-cpufreq-installer
cd ..
rm -rf auto-cpufreq
sudo auto-cpufreq --install

# Copy wallpapers
echo "Copying wallpapers..."
mkdir -p ~/Pictures/Wallpapers ~/Pictures/Screenshots
cp -r ./Wallpapers/* ~/Pictures/Wallpapers

# Enable firewalld
echo "Enabling firewalld..."
sudo systemctl enable firewalld.service

# Add user to input group
echo "Adding user to input group..."
sudo usermod -a -G input "$USER"

# Add user to video group
echo "Adding user to video group..."
sudo usermod -a -G video "$USER"

# Enable Bluetooth
echo "Enabling Bluetooth..."
sudo systemctl enable bluetooth.service

# Configure Waybar
echo "Configuring Waybar..."
mkdir -p ~/.config/waybar
cp -r ./config/waybar/* ~/.config/waybar/
chmod +x ~/.config/waybar/scripts/*.sh

# Configure Pcmanfm-qt
echo "Configuring Pcmanfm-qt..."
cp -r ./config/pcmanfm-qt ~/.config/

# Configure Fastfetch
echo "Configuring Fastfetch..."
cp -r ./config/fastfetch ~/.config/

# Configure Pywal setup
echo "Configuring Pywal..."
mkdir -p ~/.config/wal/templates ~/.config/presets/user
cp -r ./pywal16-libadwaita/templates/* ~/.config/wal/templates
./pywal16-libadwaita/scripts/apply-theme.sh
wal --cols16 -i ~/Pictures/Wallpapers/jama.png -n -e
gradience-cli apply -n "pywal" --gtk both

# Ensure Pipx path
echo "Ensuring Pipx path..."
pipx ensurepath

# Enable Reflector
echo "Enabling Reflector..."
sudo cp ./config/reflector.conf /etc/xdg/reflector/reflector.conf
sudo systemctl enable reflector.timer

# Ask about AMD installation
if ask_yes_no "Do you want to install AMD GPU drivers?"; then
    install_amd
else
    echo "AMD GPU installation skipped."
fi

# Ask about Nvidia installation
if ask_yes_no "Do you want to install Nvidia GPU drivers?"; then
    install_nvidia
else
    echo "Nvidia GPU installation skipped."
fi

# Install gaming packages if user agrees
if ask_yes_no "Would you like to download additional gaming packages?"; then
    echo "Downloading gaming packages..."
    sudo pacman -S --needed "${GAMING_PACKAGES[@]}"
    yay -S --needed "${GAMING_PACKAGES_YAY[@]}"
else
    echo "Skipping gaming packages."
fi

# Ask about restart
if ask_yes_no "Dotfiles successfully installed. Do you want to restart now?"; then
    sudo reboot now
else
    echo "Not restarting. Please restart in order to use the dotfiles."
fi
