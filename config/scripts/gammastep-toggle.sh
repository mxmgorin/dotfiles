#!/bin/sh
# Toggle gammastep night light by starting/stopping the process.
# Process presence is the single source of truth.

case "$1" in
    status)
        if pgrep -x gammastep >/dev/null; then
            echo '{"text":"🌙","tooltip":"Night light: on (click to disable)","class":"on"}'
        else
            echo '{"text":"☀️","tooltip":"Night light: off (click to enable)","class":"off"}'
        fi
        ;;
    toggle|*)
        if pgrep -x gammastep >/dev/null; then
            pkill -x gammastep
        else
            setsid gammastep >/dev/null 2>&1 < /dev/null &
        fi
        pkill -RTMIN+8 waybar 2>/dev/null
        ;;
esac
