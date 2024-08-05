#!/bin/bash

# Show dialogue box
zenity --info --text="You need to perform a post-install finalisation" --ok-label="Finalize installation"

# Launch when user validated the post install
if [ $? -eq 0 ]; then
    kitty --class clipse zsh ~/.config/hypr/scripts/post_install.sh
fi
