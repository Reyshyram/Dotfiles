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
sudo pacman -S micro wl-clipboard os-prober kitty hyprland qt5-graphicaleffects qt5-quickcontrols2 qt5-svg noto-fonts neofetch plymouth ttf-firacode-nerd zsh qt5-wayland qt6-wayland plymouth
yay -S sddm-git bibata-cursor-theme ttf-meslo-nerd-font-powerlevel10k 
sudo flatpak install flathub one.ablaze.floorp
sudo flatpak install flathub io.bassi.Amberol

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
sed -i 's/^GRUB_DEFAULT=.*/GRUB_DEFAULT=saved/; s/^#GRUB_SAVEDEFAULT=true/GRUB_SAVEDEFAULT=true/' /etc/default/grub
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
cp ./config/micro/settings.json ~/.config/micro/settings.json

# Plymouth theme
echo "Preparing plymouth theme..."
sudo sed -i 's/^GRUB_CMDLINE_LINUX_DEFAULT=.*/GRUB_CMDLINE_LINUX_DEFAULT="quiet splash loglevel=3 systemd.show_status=auto rd.udev.log_level=3"/' /etc/default/grub
sudo sed -i '/^\[Daemon\]/a ShowDelay=0' /etc/plymouth/plymouthd.conf
sudo grub-mkconfig -o /boot/grub/grub.cfg
sudo sed -i '/^HOOKS=/ s/)$/ plymouth)/' /etc/mkinitcpio.conf
git clone https://github.com/catppuccin/plymouth.git
sudo cp -r ./plymouth/themes/* /usr/share/plymouth/themes/
sudo rm -rf ./plymouth
sudo plymouth-set-default-theme -R catppuccin-mocha