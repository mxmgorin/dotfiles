#!/bin/bash

CHANGE="$1"
echo $CHANGE

pactl set-sink-volume @DEFAULT_SINK@ "$CHANGE%"

#grep -oP '[0-9]+(?=%)': Extracts all numbers immediately followed by a %.
#head -n 1: Grabs just the first percentage (left or right channel — they’re usually the same).
current=$(pactl get-sink-volume @DEFAULT_SINK@ | grep -oP '[0-9]+(?=%)' | head -n 1)
sink=$(pactl get-default-sink)
name_after_last_dot="${sink##*.}"

notify-send -a "system-script" -e -u "low" -h string:x-canonical-private-synchronous:volume_notif -h int:value:$current -u low -i "$icon" "Audio" "Volume ($name_after_last_dot): $current%"
