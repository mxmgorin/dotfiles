#!/bin/sh
# Output the active power profile as a waybar custom module JSON payload.

profile="$(powerprofilesctl get 2>/dev/null)"
case "$profile" in
    performance) icon=$(printf "\xef\x83\xa7") ;;
    balanced)    icon=$(printf "\xef\x89\x8e") ;;
    power-saver) icon=$(printf "\xef\x81\xac") ;;
    *)           icon="?"; profile="${profile:-unknown}" ;;
esac

printf '{"text":"%s","tooltip":"Power profile: %s","class":"%s"}\n' "$icon" "$profile" "$profile"
