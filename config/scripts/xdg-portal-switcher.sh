#!/bin/bash
set -e

# Detect Wayland session name
SESSION="$XDG_SESSION_DESKTOP"

# Default fallback to KDE
TARGET="portals.kde.conf"

if [[ "$SESSION" == "niri" ]]; then
  TARGET="portals.niri.conf"
fi

# Switch portal config
mkdir -p ~/.config/xdg-desktop-portal/
cp "$HOME/.config/xdg-desktop-portal/$TARGET" "$HOME/.config/xdg-desktop-portal/portals.conf"

# Restart portal
systemctl --user restart xdg-desktop-portal.service
