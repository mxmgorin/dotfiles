#!/bin/bash

# Get all sinks in order
mapfile -t sinks < <(pactl list short sinks | awk '{print $2}')

# Get current default sink
default_sink=$(pactl info | grep "Default Sink" | cut -d ':' -f2 | xargs)

# Find index of current default
current_index=-1
for i in "${!sinks[@]}"; do
    if [[ "${sinks[$i]}" == "$default_sink" ]]; then
        current_index=$i
        break
    fi
done

# Determine next sink in list (loop around)
if [[ $current_index -ge 0 ]]; then
    next_index=$(( (current_index + 1) % ${#sinks[@]} ))
    next_sink="${sinks[$next_index]}"
else
    echo "Default sink not found in sink list."
    exit 1
fi

# Set new default sink
pactl set-default-sink "$next_sink"

# Move all active sink inputs to new sink
for input in $(pactl list short sink-inputs | awk '{print $1}'); do
    pactl move-sink-input "$input" "$next_sink"
done

# Get friendly name
desc=$(pactl list sinks | awk -v sink="$next_sink" '
    $0 ~ "Name: "sink { show=1 }
    show && /Description:/ {
        gsub(/^[[:space:]]*Description: /, "", $0)
        print $0
        exit
    }')

# Notify
notify-send -u low -e -a "system-script" "Audio" "Switched to: $desc"
