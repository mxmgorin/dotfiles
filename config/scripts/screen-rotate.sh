#!/bin/sh
# Toggle the focused output between portrait (270) and landscape (normal).
# Reports the current state for waybar's custom module.

get_focused_output() {
    niri msg focused-output 2>/dev/null \
        | awk '/^Output / { match($0, /\(([^)]+)\)/, m); print m[1]; exit }'
}

get_transform() {
    out="$1"
    niri msg outputs 2>/dev/null | awk -v out="$out" '
        /^Output / {
            match($0, /\(([^)]+)\)/, m)
            current = m[1]
        }
        current == out && /^[[:space:]]+Transform:/ {
            val = $2
            sub(/°$/, "", val)
            print val
            exit
        }
    '
}

is_portrait() {
    case "$1" in
        90|270|flipped-90|flipped-270) return 0 ;;
        *) return 1 ;;
    esac
}

case "$1" in
    status)
        out="$(get_focused_output)"
        tr="$(get_transform "$out")"
        if is_portrait "$tr"; then
            printf '{"text":"📱","tooltip":"%s: portrait — click for landscape","class":"portrait"}\n' "$out"
        else
            printf '{"text":"🖥️","tooltip":"%s: landscape — click for portrait","class":"landscape"}\n' "$out"
        fi
        ;;
    toggle|*)
        out="$(get_focused_output)"
        tr="$(get_transform "$out")"
        if is_portrait "$tr"; then
            niri msg output "$out" transform normal
        else
            niri msg output "$out" transform 270
        fi
        pkill -RTMIN+9 waybar 2>/dev/null
        ;;
esac
