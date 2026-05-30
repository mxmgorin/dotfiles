#!/bin/bash
# Pick a power profile via fuzzel menu and apply it.

options="power-saver\nbalanced\nperformance"
choice=$(echo -e "$options" | fuzzel --dmenu --lines 3 -w 20)

if [ -n "$choice" ]; then
    powerprofilesctl set "$choice"
    notify-send -e -u low -a "system-script" \
        -h string:x-canonical-private-synchronous:power_notif \
        "Power Profile" "$choice"
    pkill -RTMIN+10 waybar 2>/dev/null
fi
