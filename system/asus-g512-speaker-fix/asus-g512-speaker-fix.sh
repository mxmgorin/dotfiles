#!/bin/bash
# Enable internal speaker amplifier on ASUS ROG Strix G512LW/LV (Realtek ALC294).
# Sends the two COEF writes the upstream ALC294_FIXUP_ASUS_G512_SPK fixup applies:
#   COEF index 0x0f <- 0x7778
#   COEF index 0x40 <- 0x0800
# Without these the internal speakers stay silent (jack + HDMI work fine).

hw=""
for c in /proc/asound/card*/codec#0; do
    if grep -q "ALC294" "$c" 2>/dev/null; then
        n=$(echo "$c" | grep -oP 'card\K[0-9]+')
        hw="/dev/snd/hwC${n}D0"
        break
    fi
done

if [ -z "$hw" ]; then
    echo "asus-g512-speaker-fix: ALC294 codec not found, nothing to do" >&2
    exit 0
fi

hda-verb "$hw" 0x20 0x500 0x0f
hda-verb "$hw" 0x20 0x400 0x7778
hda-verb "$hw" 0x20 0x500 0x40
hda-verb "$hw" 0x20 0x400 0x0800
