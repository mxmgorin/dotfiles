#!/bin/bash

if ip route show 2>/dev/null | grep -qE '^(0\.0\.0\.0|128\.0\.0\.0)/1 .*dev amn'; then
    # Connected
    echo '{"text": "", "class": "connected", "tooltip": "VPN connected"}'
else
    # Not connected
    echo '{"text": " ", "class": "disconnected", "tooltip": "VPN disconnected"}'
fi
