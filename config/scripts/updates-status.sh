#!/bin/sh
# Show pending pacman + AUR update count for waybar.
#
# Two modes:
#   status   — print cached JSON immediately (fast, used by waybar)
#   refresh  — re-run checkupdates / yay -Qua and rewrite the cache (slow, runs in background)
#
# The cache lives at $XDG_RUNTIME_DIR/updates.cache and is updated periodically
# by a `spawn-at-startup` loop in Niri.

CACHE="${XDG_RUNTIME_DIR:-/tmp}/updates.cache"

emit() {
    repo=$1
    aur=$2
    total=$((repo + aur))
    if [ "$total" -eq 0 ]; then
        printf '{"text":"","tooltip":"System up to date","class":"none"}\n'
        return
    fi
    if   [ "$total" -ge 50 ]; then class="critical"
    elif [ "$total" -ge 20 ]; then class="warning"
    else                            class="some"
    fi
    printf '{"text":"󰚰 %d","tooltip":"Repo: %d\\nAUR: %d","class":"%s"}\n' \
        "$total" "$repo" "$aur" "$class"
}

case "${1:-status}" in
    refresh)
        repo=$(checkupdates 2>/dev/null | wc -l)
        aur=$(yay -Qua 2>/dev/null | wc -l)
        printf '%d %d\n' "$repo" "$aur" > "$CACHE"
        pkill -RTMIN+11 waybar 2>/dev/null
        ;;
    daemon)
        # Refresh once at startup, then every 30 minutes.
        while :; do
            "$0" refresh
            sleep 1800
        done
        ;;
    status|*)
        if [ -r "$CACHE" ]; then
            read -r repo aur < "$CACHE"
            emit "${repo:-0}" "${aur:-0}"
        else
            printf '{"text":"…","tooltip":"Updates: checking...","class":"checking"}\n'
        fi
        ;;
esac
