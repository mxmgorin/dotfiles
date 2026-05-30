#!/bin/bash
# Change screen brightness on internal (backlight) and external (DDC) displays.
# Usage: change-brightness.sh +5  |  change-brightness.sh -10

set -u

CHANGE="${1:?Usage: $0 <+N|-N>}"
EXT_DISPLAY="1"  # ddcutil --display id for the external monitor
MIN=5            # never go below this — fully black screen is no fun

LOCKFILE="/tmp/brightness.lock"

# Single instance: skip silently if another invocation is mid-flight (key spam).
exec 200>"$LOCKFILE" || exit 1
flock -n 200 || exit 0

clamp() {  # clamp <value> <min> <max>
    local v=$1 lo=$2 hi=$3
    (( v < lo )) && v=$lo
    (( v > hi )) && v=$hi
    echo "$v"
}

brightness_icon() {
    local level=$1
    if   (( level <= 20 )); then echo "display-brightness-low-symbolic"
    elif (( level <= 60 )); then echo "display-brightness-medium-symbolic"
    else                         echo "display-brightness-high-symbolic"
    fi
}

# --- Internal (laptop) backlight via brightnessctl --------------------------
internal_current=$(brightnessctl -c backlight get)
internal_max=$(brightnessctl -c backlight max)
internal_pct=$(( internal_current * 100 / internal_max ))
internal_new=$(clamp $(( internal_pct + CHANGE )) $MIN 100)

if (( internal_new != internal_pct )); then
    brightnessctl -c backlight set "${internal_new}%" >/dev/null
fi

# --- External monitor via DDC/CI (fire-and-forget, relative change) ---------
# ddcutil over I2C is slow (~500ms). Use relative setvcp and run in background
# so the keypress feels instant; the monitor catches up shortly after.
if command -v ddcutil >/dev/null 2>&1; then
    sign="${CHANGE:0:1}"           # "+" or "-"
    magnitude="${CHANGE#[+-]}"     # digits without sign
    setsid ddcutil --display "$EXT_DISPLAY" setvcp 10 "$sign" "$magnitude" \
        >/dev/null 2>&1 < /dev/null &
    disown
fi

# --- Notify -----------------------------------------------------------------
icon=$(brightness_icon "$internal_new")
notify-send -e -a "system-script" \
    -h string:x-canonical-private-synchronous:brightness_notif \
    -h int:value:"$internal_new" \
    -u low -i "$icon" \
    "Brightness" "${internal_new}%"
