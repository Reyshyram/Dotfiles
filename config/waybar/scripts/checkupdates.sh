#!/bin/bash

IFS=$'\n'$'\r'

mapfile -t updates < <(checkupdates && pacman -Qm | aur vercmp)

text=${#updates[@]}
tooltip="<b>$text  updates (arch+aur)</b>"
[ "$text" -eq 0 ] && text="" || text+=" "

cat <<EOF
{ "text":"$text", "tooltip":"$tooltip"}  
EOF