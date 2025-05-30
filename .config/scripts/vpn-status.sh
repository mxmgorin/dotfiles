#!/bin/bash

if pgrep -f wireguard > /dev/null; then
    # Connected
    echo '{"text": "", "class": "connected", "tooltip": "VPN connected"}'
else
    # Not connected
    echo '{"text": " ", "class": "disconnected", "tooltip": "VPN disconnected"}'
fi
