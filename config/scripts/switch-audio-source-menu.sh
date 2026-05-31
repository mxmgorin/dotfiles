#!/bin/bash
# Pick an audio source (microphone) by human-readable description via fuzzel.
# Monitor sources (.monitor) are excluded — they mirror outputs, not real mics.

# Toggle: if a fuzzel menu is already open, close it and exit.
if pkill -x fuzzel; then
    exit 0
fi

declare -A desc_to_name
current_name=""
current_desc=""

while IFS= read -r line; do
    if [[ "$line" =~ ^[[:space:]]*Name:\ (.+)$ ]]; then
        current_name="${BASH_REMATCH[1]}"
    elif [[ "$line" =~ ^[[:space:]]*Description:\ (.+)$ ]]; then
        current_desc="${BASH_REMATCH[1]}"
        if [[ -n "$current_name" && -n "$current_desc" && "$current_name" != *.monitor ]]; then
            desc_to_name["$current_desc"]="$current_name"
        fi
        current_name=""
        current_desc=""
    fi
done < <(pactl list sources)

default_source=$(pactl info | awk -F': ' '/Default Source/ {print $2}')

options=()
for desc in "${!desc_to_name[@]}"; do
    name="${desc_to_name[$desc]}"
    if [[ "$name" == "$default_source" ]]; then
        options+=("● $desc")
    else
        options+=("  $desc")
    fi
done
mapfile -t options < <(printf '%s\n' "${options[@]}" | sort)

selected=$(printf '%s\n' "${options[@]}" | fuzzel --dmenu -p "Microphone: ")
[[ -z "$selected" ]] && exit 0

desc="${selected:2}"
name="${desc_to_name[$desc]}"
[[ -z "$name" ]] && exit 1

pactl set-default-source "$name"
for output in $(pactl list short source-outputs | awk '{print $1}'); do
    pactl move-source-output "$output" "$name"
done

notify-send -u low -e -a "system-script" \
    -h string:x-canonical-private-synchronous:audio_source_notif \
    "Microphone" "$desc"
