#!/bin/bash

pkill -x "wlogout" || wlogout -b 6 -c 0 -r 0 -L 100 -R 100 --css "$HOME/.config/wlogout/style.css" --protocol layer-shell