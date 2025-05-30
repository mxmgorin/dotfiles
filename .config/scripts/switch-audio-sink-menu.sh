#!/bin/bash

# Get list of sinks (full name and index)
mapfile -t sinks < <(pactl list short sinks)

# Build mapping: short_name -> full_name
declare -A sink_map
options=()
for sink in "${sinks[@]}"; do
    sink_index=$(echo "$sink" | awk '{print $1}')
    sink_name=$(echo "$sink" | awk '{print $2}')
    short_name="${sink_name##*.}"  # part after last dot
    sink_map["$short_name"]="$sink_name"
    options+=("$short_name")
done

# Join options with newlines and pass to fuzzel
selected=$(printf '%s\n' "${options[@]}" | fuzzel --dmenu -p "Select Sink: ")

if [[ -n "$selected" ]]; then
    full_name="${sink_map[$selected]}"
    sink_index=$(printf '%s\n' "${sinks[@]}" | grep "$full_name" | awk '{print $1}')

    pactl set-default-sink "$sink_index"

    # Move current audio streams to new sink
    for input in $(pactl list short sink-inputs | awk '{print $1}'); do
        pactl move-sink-input "$input" "$sink_index"
    done

    notify-send -u "low" -e -a "system-script" "Audio" "Output switched to: $selected"
fi
