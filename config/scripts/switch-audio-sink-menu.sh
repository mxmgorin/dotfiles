#!/bin/bash
# Pick an audio sink (output) by human-readable description via fuzzel.

# Build name <-> description mapping from `pactl list sinks`.
declare -A desc_to_name
declare -A name_to_desc
current_name=""
current_desc=""

while IFS= read -r line; do
    if [[ "$line" =~ ^[[:space:]]*Name:\ (.+)$ ]]; then
        current_name="${BASH_REMATCH[1]}"
    elif [[ "$line" =~ ^[[:space:]]*Description:\ (.+)$ ]]; then
        current_desc="${BASH_REMATCH[1]}"
        if [[ -n "$current_name" && -n "$current_desc" ]]; then
            desc_to_name["$current_desc"]="$current_name"
            name_to_desc["$current_name"]="$current_desc"
            current_name=""
            current_desc=""
        fi
    fi
done < <(pactl list sinks)

default_sink=$(pactl info | awk -F': ' '/Default Sink/ {print $2}')

# Build menu, marking the active one.
options=()
for desc in "${!desc_to_name[@]}"; do
    name="${desc_to_name[$desc]}"
    if [[ "$name" == "$default_sink" ]]; then
        options+=("● $desc")
    else
        options+=("  $desc")
    fi
done
mapfile -t options < <(printf '%s\n' "${options[@]}" | sort)

selected=$(printf '%s\n' "${options[@]}" | fuzzel --dmenu -p "Output: ")
[[ -z "$selected" ]] && exit 0

# Strip the active marker.
desc="${selected:2}"
name="${desc_to_name[$desc]}"
[[ -z "$name" ]] && exit 1

pactl set-default-sink "$name"
for input in $(pactl list short sink-inputs | awk '{print $1}'); do
    pactl move-sink-input "$input" "$name"
done

notify-send -u low -e -a "system-script" \
    -h string:x-canonical-private-synchronous:audio_sink_notif \
    "Audio output" "$desc"
