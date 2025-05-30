#!/bin/bash

# Usage: ./ddc-brightness.sh +5 or -10

CHANGE="$1"
DISPLAY="1"  # Change if your external monitor uses a different display ID
MAX_ATTEMPTS=20
ATTEMPT=0
LOCKFILE="/tmp/ddc-brightness.lock"

notify_user() {
	notify-send -e -a "system-script" -h string:x-canonical-private-synchronous:brightness_notif -h int:value:$NEW -u low -i "$icon" "Brightness Level:" "$NEW%"
}

# Lock to prevent concurrent runs
exec 200>"$LOCKFILE"

until flock -n 200; do
  ((ATTEMPT++))

  if (( ATTEMPT >= MAX_ATTEMPTS )); then
    echo "Failed to acquire lock after $MAX_ATTEMPTS attempts."
     exit 1
  fi

  sleep 0.1  # Optional: pause for 100ms between attempts
done

# Get current brightness
CURRENT_DISPLAY1=$(ddcutil --display 1 getvcp 10 2>/dev/null | grep -oP 'current value =\s*\K[0-9]+')

# Calculate new brightness
NEW=$(($CURRENT_DISPLAY1 $CHANGE))

# Clamp between 0 and 100
if (( NEW > 100 )); then NEW=100; fi
if (( NEW < 0 )); then NEW=0; fi

if (( CURRENT_DISPLAY1 != NEW )); then


  ddcutil --display "$DISPLAY" setvcp 10 "$NEW"
fi

CURRENT_INTERNAL=$(brightnessctl i | grep -oP '\(\K[0-9]+(?=%\))')
NEW=$(($CURRENT_INTERNAL $CHANGE))
if (( NEW > 100 )); then NEW=100; fi
if (( NEW < 10 )); then NEW=10; fi
if (( CURRENT_INTERNAL != NEW)) then brightnessctl -c backlight set $NEW%; fi

echo "Changed brightness: $NEW"
notify_user
