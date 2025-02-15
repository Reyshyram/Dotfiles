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
        sudo pacman -S --needed git base-devel
        git clone https://aur.archlinux.org/yay.git
        cd yay
        makepkg -si
        cd .. && rm -rf yay
        export PATH="$PATH:$HOME/.local/bin"
    else
        echo "yay is already installed."
    fi
}

# Function to enable chaotic aur
enable_chaotic_aur() {
    if grep -q "\[chaotic-aur\]" /etc/pacman.conf; then
        echo "Chaotic AUR is already enabled."
    else
        echo "Enabling Chaotic AUR..."
        sudo pacman-key --recv-key 3056513887B78AEB --keyserver keyserver.ubuntu.com
        sudo pacman-key --lsign-key 3056513887B78AEB
        sudo pacman -U 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst'
        sudo pacman -U 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst'
        echo -e '\n[chaotic-aur]\nInclude = /etc/pacman.d/chaotic-mirrorlist' | sudo tee -a /etc/pacman.conf
        sudo pacman -Sy
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

    if ask_yes_no "Do you have an RTX gpu?"; then
        sudo pacman -S --needed nvidia-open-dkms
    else
        sudo pacman -S --needed nvidia-dkms
    fi

    sudo pacman -S --needed nvidia-utils lib32-nvidia-utils nvidia-settings opencl-nvidia egl-wayland libva-nvidia-driver
    
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

    echo "Adding kernel parameter to refind..."
    sudo sed -i '/"Boot using default options"/s/\(.*\)"/\1 nvidia.NVreg_PreserveVideoMemoryAllocations=1"/' /boot/refind_linux.conf
}

# Packages to install
PACKAGES=(
    micro wl-clipboard os-prober kitty hyprland qt5-graphicaleffects
    qt5-quickcontrols2 qt5-svg noto-fonts noto-fonts-cjk fastfetch plymouth
    ttf-firacode-nerd zsh qt5-wayland qt6-wayland pipewire wireplumber
    xdg-desktop-portal-hyprland pacman-contrib btop nwg-look qt5ct qt6ct
    papirus-icon-theme kvantum sddm brightnessctl pamixer playerctl
    xdg-user-dirs sound-theme-freedesktop yad jq vlc gwenview tumbler
    ffmpegthumbnailer polkit-gnome udiskie grim socat wireplumber
    networkmanager pipewire-alsa pipewire-audio pipewire-jack pipewire-pulse
    gst-plugin-pipewire slurp noto-fonts-emoji firewalld
    waybar xdg-desktop-portal-gtk bluez bluez-utils blueman
    network-manager-applet pavucontrol ttf-meslo-nerd gnome-keyring kooha
    kvantum-qt5 gnome-disk-utility firefox swaync hyprlock hypridle
    python-pipx pcmanfm-qt ark cpio meson cmake hyprwayland-scanner man
    libreoffice-fresh evince gnome-clocks 7zip unrar swww imagemagick
    gstreamer gst-plugins-bad gst-plugins-base gst-plugins-good
    gst-plugins-ugly pkgconf pinta vim fzf reflector zoxide wget
    zenity baobab gnome-font-viewer unzip ttf-ubuntu-font-family
    python-pillow python-scikit-learn python-numpy curl
    qt6-5compat qt6-declarative qt6-svg openrgb bc wlr-randr
    adw-gtk-theme libadwaita wl-clip-persist zip
    xwaylandvideobridge nwg-displays gdb refind
)

# AUR packages to install
YAY_PACKAGES=(
    bibata-cursor-theme visual-studio-code-bin gapless hardcode-fixer-git
    wlogout github-desktop auto-cpufreq
    hyprpicker grimblast-git aurutils arch-update 
    python-pywal16 smile clipse swayosd-git waypaper
    ttf-meslo-nerd-font-powerlevel10k python-haishoku dopamine-appimage-preview
    python-screeninfo python-imageio ulauncher-git
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
    vkbasalt lib32-vkbasalt proton-ge-custom dxvk-bin vesktop protontricks
)

echo "Installing Reyshyram's dotfiles..."

# Enhance git
echo "Enhancing git..."
git config --global http.postBuffer 157286400

# Enhance pacman
echo "Configuring pacman..."
sudo sed -i 's/^#Color/Color/; s/^#VerbosePkgLists/VerbosePkgLists/; s/^#ParallelDownloads = 5/ParallelDownloads = 5/' /etc/pacman.conf
enable_multilib

# Install yay
install_yay
enable_chaotic_aur

# Make package compression faster
echo "Reducing package compression time..."
sudo sed -i 's/COMPRESSZST=(zstd -c -T0 --ultra -20 -)/COMPRESSZST=(zstd -c -T0 --fast -)/' /etc/makepkg.conf

# Enable TRIM for SSDs
sudo systemctl enable fstrim.timer

# Install additional packages
echo "Installing required packages..."
sudo pacman -S --needed "${PACKAGES[@]}"
yay -S --needed "${YAY_PACKAGES[@]}"

# Configure SDDM
echo "Configuring SDDM..."
sudo mkdir -p /usr/share/sddm/themes/
sudo cp -r ./config/sddm/sddm-astronaut /usr/share/sddm/themes/
sudo cp ./config/sddm/sddm.conf /etc/sddm.conf
sudo chown $USER /usr/share/sddm/themes/sddm-astronaut/theme.conf
sudo chown $USER /usr/share/sddm/themes/sddm-astronaut/background.png
sudo chown $USER /usr/share/sddm/themes/sddm-astronaut/
systemctl enable sddm.service

# Configure Refind
echo "Configuring Refind..."
sudo refind-install
sudo mkdir -p /boot/EFI/refind/themes/
sudo cp -r ./config/refind/* /boot/EFI/refind/themes/
cat << EOF | sudo tee -a /boot/EFI/refind/refind.conf
timeout 5
resolution max
use_graphics_for osx,linux,windows
extra_kernel_version_strings "linux-hardened,linux-rt-lts,linux-zen,linux-lts,linux-rt,linux"
include themes/shadow-refind/theme.conf
EOF

CONFIG_FILE="/boot/refind_linux.conf"
ROOT_VALUE=$(grep -oP 'root=\K(PARTUUID=[a-fA-F0-9-]+|UUID=[a-fA-F0-9-]+|/dev/[a-zA-Z0-9]+)' "$CONFIG_FILE" | head -n 1)
NEW_CONTENT=$(cat <<EOF
\"Boot using default options\"     \"root=$ROOT_VALUE rw add_efi_memmap quiet splash loglevel=3 systemd.show_status=auto rd.udev.log_level=3\"
\"Boot using fallback initramfs\"  \"root=$ROOT_VALUE rw add_efi_memmap initrd=boot\\initramfs-%v-fallback.img\"
\"Boot to terminal\"               \"root=$ROOT_VALUE rw add_efi_memmap systemd.unit=multi-user.target\"
EOF
)
sudo bash -c "echo \"$NEW_CONTENT\" > $CONFIG_FILE"
echo "Successfully updated $CONFIG_FILE."

# Configure Kitty
echo "Configuring Kitty..."
mkdir -p ~/.config/kitty
cp -r ./config/kitty/* ~/.config/kitty
mkdir -p ~/.local/bin
cp ./config/xdg-terminal-exec ~/.local/bin/xdg-terminal-exec
chmod +x ~/.local/bin/xdg-terminal-exec

# Configure Zsh
echo "Configuring Zsh..."
chsh -s "$(which zsh)"
sudo chsh -s "$(which zsh)"
cp ./config/.zshrc ~/.zshrc
cp ./config/.zprofile ~/.zprofile
cp ./config/.p10k.zsh ~/.p10k.zsh

# Configure Micro theme
echo "Configuring Micro theme..."
mkdir -p ~/.config/micro/
cp ./config/micro/* ~/.config/micro/

# Configure Plymouth
echo "Configuring Plymouth..."
sudo sed -i '/^\[Daemon\]/a ShowDelay=0' /etc/plymouth/plymouthd.conf
sudo sed -i '/^HOOKS=/ s/)$/ plymouth)/' /etc/mkinitcpio.conf
sudo cp -r ./config/plymouth/black_hud /usr/share/plymouth/themes/
sudo plymouth-set-default-theme -R black_hud

# Configure Btop
echo "Configuring Btop..."
mkdir -p ~/.config/btop/
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

# Configure SwayOSD
echo "Configuring SwayOSD..."
mkdir -p ~/.config/swayosd
cp -r ./config/swayosd/* ~/.config/swayosd/


# Configure Hyprland
echo "Configuring Hyprland..."
mkdir -p ~/.config/hypr
cp -r ./config/hypr/* ~/.config/hypr/
chmod +x ~/.config/hypr/scripts/*.sh
# Send notification post install when restarting
echo "exec-once = ~/.config/hypr/scripts/post_install_listener.sh" >> ~/.config/hypr/startup.conf
# User icon
ln -s -f ~/.config/hypr/profile-picture.png ~/.face.icon
ln -s -f ~/.config/hypr/profile-picture.png ~/.face

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

# Configure Wlogout
echo "Configuring Wlogout..."
cp -r ./config/wlogout ~/.config/

# Enable auto-cpufreq
echo "Enabling auto-cpufreq..."
systemctl enable --now auto-cpufreq 

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

# Configure clipse
echo "Configuring clipse..."
cp -r ./config/clipse ~/.config/

# Configure Waypaper
echo "Configuring Waypaper..."
cp -r ./config/waypaper ~/.config/

# Configure Ulauncher
echo "Configuring Ulauncher..."
systemctl --user enable --now ulauncher
cp -r ./config/ulauncher ~/.config/

# Configure Pywal setup
echo "Configuring Pywal..."
mkdir -p ~/.config/wal/templates ~/.config/Kvantum/pywal
cp -r ./config/pywal/templates/* ~/.config/wal/templates/

ln -f -s "$HOME/.cache/wal/gtk.css" "$HOME/.config/gtk-3.0/gtk.css"
ln -f -s "$HOME/.cache/wal/gtk.css" "$HOME/.config/gtk-4.0/gtk.css"

ln -f -s "$HOME/.cache/wal/pywal.kvconfig" "$HOME/.config/Kvantum/pywal/pywal.kvconfig"
ln -f -s "$HOME/.cache/wal/pywal.svg" "$HOME/.config/Kvantum/pywal/pywal.svg"

/usr/bin/wal --cols16 -i ~/Pictures/Wallpapers/anime-rose.png -n -e --backend haishoku
python "$HOME/.config/hypr/scripts/pywal-accent-color.py" ~/Pictures/Wallpapers/anime-rose.png

# Ensure Pipx path
echo "Ensuring Pipx path..."
pipx ensurepath

# Enable 21tor
echo "Enabling Reflector..."
sudo cp ./config/reflector.conf /etc/xdg/reflector/reflector.conf
sudo systemctl start reflector.timer
sudo systemctl enable reflector.timer

# Ask about using a laptop
if ask_yes_no "Are you using a laptop?"; then
    yay -S --needed batsignal
    systemctl --user enable batsignal.service
    systemctl --user start batsignal.service
    mkdir -p ~/.config/systemd/user/batsignal.service.d
    printf '[Service]\nExecStart=\nExecStart=batsignal -d 5 -c 15 -w 30 -p' > ~/.config/systemd/user/batsignal.service.d/options.conf
else
    echo "Laptop installation skipped installation skipped."
fi

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
