#!/bin/bash

# Allowed sources to cycle through
allowed_sources=(
  "alsa_input.pci-0000_00_1f.3.analog-stereo"
  "alsa_input.usb-SteelSeries_SteelSeries_Arctis_7-00.mono-chat"
)

# Get current default source
default_source=$(pactl info | grep "Default Source" | cut -d ':' -f2 | xargs)

# Build filtered list and pretty names
declare -A source_map
options=()

for source_name in "${allowed_sources[@]}"; do
    # Get friendly description dynamically
    pretty_name=$(pactl list sources | awk -v src="$source_name" '
        $0 ~ "Name: "src { show=1 }
        show && /Description:/ {
            gsub(/^[[:space:]]*Description: /, "", $0)
            print $0
            exit
        }')

    # Mark default source
    if [[ "$source_name" == "$default_source" ]]; then
        pretty_name+=" (default)"
    fi

    source_map["$pretty_name"]="$source_name"
    options+=("$pretty_name")
done

# Find current default index in options
current_index=-1
for i in "${!options[@]}"; do
    # Strip " (default)" for comparison
    name="${options[$i]%% (default)}"
    if [[ "${source_map[${options[$i]}]}" == "$default_source" ]]; then
        current_index=$i
        break
    fi
done

# Determine next index (loop)
if [[ $current_index -ge 0 ]]; then
    next_index=$(( (current_index + 1) % ${#options[@]} ))
else
    next_index=0
fi

next_pretty="${options[$next_index]}"
next_source="${source_map[$next_pretty]}"

# Set new default source
pactl set-default-source "$next_source"

# Move all active source outputs to new source
for output in $(pactl list short source-outputs | awk '{print $1}'); do
    pactl move-source-output "$output" "$next_source"
done

# Notify (strip default mark for display)
notify_name="${next_pretty%% (default)}"
notify-send -u low -e -a "system-script" "Microphone" "Switched to: $notify_name"
