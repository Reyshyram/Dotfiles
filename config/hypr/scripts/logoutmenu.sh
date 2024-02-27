#!/bin/bash

# Check if wlogout is already running
if pgrep -x "wlogout" > /dev/null
then
    pkill -x "wlogout"
    exit 0
fi

# launch wlogout
wlogout -b 6 -c 0 -r 0 -m 0 --css "$HOME/.config/wlogout/style" --protocol layer-shell