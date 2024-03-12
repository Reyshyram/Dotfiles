#!/bin/bash

check() {
	command -v "$1" 1>/dev/null
}

notify() {
	check notify-send && {
		notify-send "$@"
		return
	}
	echo "$@"
}

stringToLen() {
	STRING="$1"
	LEN="$2"
	if [ ${#STRING} -gt "$LEN" ]; then
		echo "${STRING:0:$((LEN - 2))}.."
	else
		printf "%-20s" "$STRING"
	fi
}

IFS=$'\n'$'\r'

mapfile -t updates < <(checkupdates && pacman -Qm | aur vercmp)

text=${#updates[@]}
tooltip="<b>$text  updates (arch+aur) </b>\n"
tooltip+=" <b>$(stringToLen "PkgName" 20) $(stringToLen "PrevVersion" 20) $(stringToLen "NextVersion" 20)</b>\n"
[ "$text" -eq 0 ] && text="" || text+=" "

for i in "${updates[@]}"; do
  # shellcheck disable=2046
	update="$(stringToLen $(echo "$i" | awk '{print $1}') 20)"
  # shellcheck disable=2046
	prev="$(stringToLen $(echo "$i" | awk '{print $2}') 20)"
  # shellcheck disable=2046
	next="$(stringToLen $(echo "$i" | awk '{print $4}') 20)" # skipping '->' string
	tooltip+="<b> $update </b>$prev $next\n"
done
tooltip=${tooltip::-2}

cat <<EOF
{ "text":"$text", "tooltip":"$tooltip"}  
EOF
