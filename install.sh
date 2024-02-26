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
sudo pacman -S --needed git base-devel
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si
cd ..
rm -rf yay
sudo pacman -S micro wl-clipboard os-prober kitty hyprland qt5-graphicaleffects qt5-quickcontrols2 qt5-svg noto-fonts neofetch plymouth ttf-firacode-nerd zsh qt5-wayland qt6-wayland plymouth pipewire wireplumber xdg-desktop-portal-hyprland xdg-desktop-portal-gtk pacman-contrib nemo gnome-keyring btop polkit-kde-agent nwg-look qt5ct qt6ct papirus-icon-theme kvantum gnome-themes-extra
yay -S sddm-git bibata-cursor-theme ttf-meslo-nerd-font-powerlevel10k visual-studio-code-bin floorp-bin amberol swaync hardcode-fixer-git papirus-folders-catppuccin-git catppuccin-gtk-theme-mocha

# SDDM Configuration
echo "Preparing SDDM theme..."
systemctl enable sddm.service
sudo mkdir -p /etc/sddm.conf.d/
sudo cp -r ./config/sddm/sugar-candy /usr/share/sddm/themes/
sudo cp ./config/sddm/sddm.conf /etc/sddm.conf.d/kde_settings.conf

# Grub theme and configuration
echo "Preparing grub theme..."
git clone https://github.com/catppuccin/grub.git
sudo mkdir -p /usr/share/grub/themes/
sudo cp -r ./grub/src/* /usr/share/grub/themes/
rm -rf ./grub
sudo sed -i 's/^#GRUB_DISABLE_OS_PROBER=false/GRUB_DISABLE_OS_PROBER=false/' /etc/default/grub
sudo sed -i 's|^#GRUB_THEME="/path/to/gfxtheme"|GRUB_THEME="/usr/share/grub/themes/catppuccin-mocha-grub-theme/theme.txt""|' /etc/default/grub
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
git clone https://github.com/catppuccin/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting/themes/catppuccin
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
git clone https://github.com/catppuccin/plymouth.git
sudo cp -r ./plymouth/themes/* /usr/share/plymouth/themes/
sudo rm -rf ./plymouth
sudo plymouth-set-default-theme -R catppuccin-mocha

# Disable mouse acceleration
echo "Disabling mouse acceleration..."
sudo sed -i '/Identifier "libinput pointer catchall"/,/^EndSection/{/^EndSection/i \        Option "Accel Profile Enabled" "0 1 0"
}' /usr/share/X11/xorg.conf.d/40-libinput.conf

# Btop theme
echo "Preparing btop theme..."
mkdir -p ~/.config/btop/themes/
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

# Applications Associations
xdg-settings set default-web-browser floorp.desktop
xdg-mime default nemo.desktop inode/directory

# Papyrus icon theme
echo "Applying icon theme..."
sudo hardcode-fixer
papirus-folders -C cat-mocha-lavender

# Load nemo config
dconf load /org/nemo/ < ./config/nemo.dconf

# Gtk theme
echo "Applying Gtk theme..."
mkdir -p ~/.config/gtk-4.0
sudo ln -sf /usr/share/themes/Catppuccin-Mocha-Standard-Lavender-Dark/gtk-4.0/assets ~/.config/gtk-4.0/assets
sudo ln -sf /usr/share/themes/Catppuccin-Mocha-Standard-Lavender-Dark/gtk-4.0/gtk.css ~/.config/gtk-4.0/gtk.css
sudo ln -sf /usr/share/themes/Catppuccin-Mocha-Standard-Lavender-Dark/gtk-4.0/gtk-dark.css ~/.config/gtk-4.0/gtk-dark.css
cp -r ./config/gtk-* ~/.config/
cp -r ./config/nwg-look ~/.config/
cp -r ./config/xsettingsd ~/.config/
cp ./config/.gtkrc-2.0 ~/.gtkrc-2.0

# QT theme
echo "Applying Qt theme..."
cp -r ./config/qt* ~/.config/
cp -r ./config/Kvantum ~/.config/
