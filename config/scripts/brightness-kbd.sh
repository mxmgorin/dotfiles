#!/bin/bash
# Script for keyboard backlights (if supported) using brightnessctl

CHANGE="$2"
ICON_DIR="$HOME/.config/icons"

get_kbd_backlight() {
	echo $(brightnessctl -d '*::kbd_backlight' -m | cut -d, -f4)
}

get_icon() {
	current=$(get_kbd_backlight | sed 's/%//')
	if   [ "$current" -le "20" ]; then
		icon="$ICON_DIR/brightness-20.png"
	elif [ "$current" -le "40" ]; then
		icon="$ICON_DIR/brightness-40.png"
	elif [ "$current" -le "60" ]; then
		icon="$ICON_DIR/brightness-60.png"
	elif [ "$current" -le "80" ]; then
		icon="$ICON_DIR/brightness-80.png"
	else
		icon="$ICON_DIR/brightness-100.png"
	fi
}

notify_user() {
	notify-send -a "system-script" -e -h string:x-canonical-private-synchronous:brightness_notif -h int:value:$current -u low -i "$icon" "Keyboard" "Brightness: $current%"
}

change_kbd_backlight() {
	brightnessctl -d *::kbd_backlight set "$1" && get_icon && notify_user
}

# Execute accordingly
case "$1" in
	"--get")
		get_kbd_backlight
		;;
	"--inc")
		change_kbd_backlight "$CHANGE%+"
		;;
	"--dec")
		change_kbd_backlight "$CHANGE%-"
		;;
	*)
		get_kbd_backlight
		;;
esac
