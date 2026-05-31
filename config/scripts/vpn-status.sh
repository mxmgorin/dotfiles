#!/bin/bash

# VPN is considered active when internet-bound traffic actually leaves
# through a tunnel interface. `ip route get` reports the real egress dev
# regardless of how routes are set up (split-default, default override,
# etc.). The prefix list covers common clients: WireGuard (wg*),
# AmneziaWG (amn*), OpenVPN/IKEv2 (tun*/tap*), PPTP/L2TP (ppp*),
# Mullvad/NordVPN/Proton, etc. Split-tunnel may need an explicit iface.
dev=$(ip route get 1.1.1.1 2>/dev/null | grep -oP 'dev \K\S+')

case "$dev" in
    tun*|tap*|wg*|amn*|ppp*|nordlynx|proton*|mullvad*|wgpia*|gpd*)
        # Connected
        echo '{"text": "", "class": "connected", "tooltip": "VPN connected ('"$dev"')"}'
        ;;
    *)
        # Not connected
        echo '{"text": " ", "class": "disconnected", "tooltip": "VPN disconnected"}'
        ;;
esac
