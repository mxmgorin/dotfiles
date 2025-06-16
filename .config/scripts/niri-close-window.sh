#!/bin/bash

TARGET_TITLE="$1"

if [ -z "$TARGET_TITLE" ]; then
    echo "Usage: $0 <exact_window_title>"
    exit 1
fi

window_id=""
current_id=""

while IFS= read -r line; do
    if [[ "$line" =~ ^Window\ ID\ ([0-9]+): ]]; then
        current_id="${BASH_REMATCH[1]}"
    fi

    if [[ "$line" =~ ^[[:space:]]+Title:\ (.+)$ ]]; then
        title="${BASH_REMATCH[1]}"
        # Remove leading and trailing quotes if present
        title="${title#\"}"
        title="${title%\"}"

        if [[ "$title" == "$TARGET_TITLE" ]]; then
            window_id="$current_id"
            break
        fi
    fi
done < <(niri msg windows)

# return id
#if [ -n "$window_id" ]; then
#    echo "$window_id"
#    exit 0
#else
#    exit 1
#fi

# closing
if [ -n "$window_id" ]; then
    echo "Closing window \"$TARGET_TITLE\" with ID $window_id"
    niri msg action close-window --id "$window_id"
    exit 0
else
    echo "No window found with title \"$TARGET_TITLE\""
    exit 1
fi
