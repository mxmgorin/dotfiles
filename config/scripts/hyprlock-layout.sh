#!/bin/sh
# Print the active niri keyboard layout as flag + short label, for hyprlock.

active="$(niri msg keyboard-layouts 2>/dev/null \
    | awk '/^\s*\*/ {sub(/^\s*\*\s*[0-9]+\s*/, ""); print; exit}')"

case "$active" in
    *Russian*) printf "🇷🇺  RU\n" ;;
    *English*) printf "🇺🇸  EN\n" ;;
    *)         printf "%s\n" "${active:-?}" ;;
esac
