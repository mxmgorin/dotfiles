#!/bin/bash

# Get current default source
default_source=$(pactl info | grep "Default Source" | cut -d ':' -f2 | xargs)

# Get list of sources (full name and index)
mapfile -t sources < <(pactl list short sources)

# Build filtered mapping
declare -A source_map
options=()

for source in "${sources[@]}"; do
    source_index=$(echo "$source" | awk '{print $1}')
    source_name=$(echo "$source" | awk '{print $2}')

    # Only include specific sources
    case "$source_name" in
        alsa_input.pci-0000_00_1f.3.analog-stereo|\
        alsa_input.usb-SteelSeries_SteelSeries_Arctis_7-00.mono-chat)
            # Get friendly description dynamically from pactl
            pretty_name=$(pactl list sources | awk -v src="$source_name" '
                $0 ~ "Name: "src { show=1 }
                show && /Description:/ {
                    gsub(/^[[:space:]]*Description: /, "", $0)
                    print $0
                    exit
                }')
            ;;
        *)
            continue  # skip everything else
            ;;
    esac

    # Mark default source
    if [[ "$source_name" == "$default_source" ]]; then
        pretty_name+=" (default)"
    fi

    source_map["$pretty_name"]="$source_name"
    options+=("$pretty_name")
done

# Show selection menu
selected=$(printf '%s\n' "${options[@]}" | fuzzel --dmenu -p "Select Source: ")

if [[ -n "$selected" ]]; then
    full_name="${source_map[$selected]}"
    source_index=$(printf '%s\n' "${sources[@]}" | grep "$full_name" | awk '{print $1}')

    pactl set-default-source "$source_index"

    # Move current audio streams to new source
    for input in $(pactl list short source-outputs | awk '{print $1}'); do
        pactl move-source-output "$input" "$source_index"
    done

    notify-send -u "low" -e -a "system-script" "Audio" "Source switched to: ${selected%% (default)}"
fi
