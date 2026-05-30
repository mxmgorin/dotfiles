#!/bin/sh
# Output a flag emoji for the currently active niri keyboard layout.
# Waybar custom module — polls; cheap enough.

layout="$(niri msg --json keyboard-layouts 2>/dev/null \
    | grep -o '"names":\[[^]]*\]' \
    | head -c -1 || true)"

# Fallback: parse human-readable output.
active="$(niri msg keyboard-layouts 2>/dev/null \
    | awk '/^\s*\*/ {sub(/^\s*\*\s*[0-9]+\s*/, ""); print; exit}')"

case "$active" in
    *Russian*)        text="🇷🇺"; tooltip="Russian" ;;
    *English*)        text="🇺🇸"; tooltip="English (US)" ;;
    *)                text="${active:-?}"; tooltip="${active:-unknown}" ;;
esac

printf '{"text":"%s","tooltip":"%s"}\n' "$text" "$tooltip"
