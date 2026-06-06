# ASUS ROG Strix G512 — keyboard backlight fix at boot

## Problem

On the **ASUS ROG Strix G512LV** (CachyOS, Niri/Wayland, `asusd` installed) the keyboard
backlight **does not turn on at boot**, even though:

- the brightness value in sysfs is already at max — `/sys/class/leds/asus::kbd_backlight/brightness` = `3`;
- the `asusd` config (`/etc/asusd/aura_1866.ron`) is correct: `brightness: High`, a static
  mode, and all power states (`boot/awake/sleep/shutdown`) = `true`.

Opening ROG Center and refreshing the brightness relights it.

Cause: `asusd` writes the aura effect to the keyboard **too early at boot** — before the
keyboard's USB/hidraw device is ready, so the write is lost.

Key detail: `asusctl leds set high` (brightness only) does **not** relight the keyboard;
only re-writing the aura **effect** (`asusctl aura effect ...`) does. So the fix
re-applies the aura mode after login.

## Dependencies

```bash
sudo pacman -S --needed asusctl   # usually already installed alongside asusd
```

## Install

This is a **user** (`--user`) systemd service bound to `graphical-session.target` — it
runs after the graphical session (Niri) is up, when the keyboard is already ready.

```bash
install -Dm644 kbd-backlight-fix.service ~/.config/systemd/user/kbd-backlight-fix.service
systemctl --user daemon-reload
systemctl --user enable --now kbd-backlight-fix.service
```

Verify:

```bash
systemctl --user status kbd-backlight-fix.service
```

## Files

- `kbd-backlight-fix.service` — user service: after `graphical-session.target` it waits
  `sleep 4`, then runs `asusctl aura effect --next-mode` + `--prev-mode` (returns to the
  same mode but forces a re-write to the hardware) + `asusctl leds set high`.

## Uninstall

```bash
systemctl --user disable --now kbd-backlight-fix.service
rm ~/.config/systemd/user/kbd-backlight-fix.service
systemctl --user daemon-reload
```

## Notes

- If on some boot the backlight still stays off (slower USB enumeration), increase
  `ExecStartPre=/usr/bin/sleep 4` to `6`–`8` and run `systemctl --user daemon-reload`.
- This service does not cover the SDDM greeter (only after login). Covering the greeter
  would need a system service `After=asusd.service`, but in practice the post-login fix
  is enough.
