#!/bin/bash

# Show dialogue box
zenity --info --text="Vous devez effectuer une finalisation post-installation" --ok-label="Finaliser l'installation"

# Launch when user validated the post install
if [ $? -eq 0 ]; then
    kitty --class clipse zsh ~/.config/hypr/scripts/post_install.sh
fi
