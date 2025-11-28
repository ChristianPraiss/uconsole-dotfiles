#!/bin/bash

ACTION=$(
	echo -e '󰤆  Shutdown\n󰑓  Restart\n󰗽  Logout' \
		| wofi --dmenu --prompt "Power Menu"
)

case "$ACTION" in
	"󰤆  Shutdown") systemctl poweroff;;
	"󰑓  Restart") systemctl reboot;;
	"󰗽  Logout") swaymsg exit;;
esac
