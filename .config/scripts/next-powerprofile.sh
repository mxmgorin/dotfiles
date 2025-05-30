#!/bin/bash

# Manually define the profile order
profiles=("power-saver" "balanced" "performance")

current=$(powerprofilesctl get)

# Find the index of the current profile
for i in "${!profiles[@]}"; do
    if [[ "${profiles[$i]}" == "$current" ]]; then
        current_index=$i
        break
    fi
done

# Calculate next index (wrap around)
next_index=$(( (current_index + 1) % ${#profiles[@]} ))

# Set the next profile
next_profile="${profiles[$next_index]}"
powerprofilesctl set "$next_profile"

notify-send -e -u "low" -a "system-script" -h string:x-canonical-private-synchronous:power_notif "Power Profile:" "$next_profile"
