# dotfiles

Personal config for a CachyOS + **Niri** (Wayland) workstation. Niri is a
scrollable-tiling compositor — these dotfiles wire it together with a polished
Waybar, fuzzel-based menus, screen lock, idle handling, and a handful of
small shell scripts that fill the gaps Niri doesn't cover natively.

## What's in here

| Path | Purpose |
| --- | --- |
| `config/niri/` | Compositor config — input, keybinds, window rules, output layout |
| `config/waybar/` | Status bar — grouped pills, custom modules, click menus |
| `config/hypr/` | `hyprlock.conf` (lock screen) and `hypridle.conf` (legacy, unused) |
| `config/dunst/` | Notification daemon styling |
| `config/wlogout/` | Power menu (logout / reboot / shutdown / lock / sleep) |
| `config/fuzzel/` | App launcher and dmenu backend for menus |
| `config/gammastep/` | Night light (warm screen at night) |
| `config/swaylock/` | Fallback screen locker |
| `config/scripts/` | Shell helpers used by Waybar/Niri — language indicator, brightness, audio source/sink pickers, power profile menu, screen rotation, gammastep toggle, etc. |
| `config/alacritty/` | Terminal config (themes excluded — clone separately, see install) |
| `config/fish/` | Shell config |
| `config/micro/` `config/helix/` `config/zed/` | Editors |
| `config/btop/` `config/lazygit/` `config/zellij/` | TUI tools |
| `config/gtk-3.0/` `config/gtk-4.0/` | GTK theming |

## Required packages

Core Wayland stack:

```
niri waybar fuzzel dunst wlogout swaylock swww swaybg
xwayland-satellite hyprlock swayidle gammastep
```

CLI tools used by scripts:

```
brightnessctl ddcutil pamixer pactl powerprofilesctl
notify-send wl-clipboard cliphist
fuzzel jq
```

Optional but referenced:

```
alacritty fish btop lazygit micro helix zed-mono zellij
asusctl playerctl blueman pavucontrol nmtui
```

Install in one go on Arch/CachyOS:

```sh
sudo pacman -S niri waybar fuzzel dunst wlogout swaylock swww swaybg \
    xwayland-satellite hyprlock swayidle gammastep \
    brightnessctl ddcutil pamixer pulseaudio-utils power-profiles-daemon \
    libnotify wl-clipboard cliphist jq alacritty fish btop lazygit \
    micro helix zed zellij playerctl blueman pavucontrol networkmanager
```

## Install

Configs are stored as plain files (not symlinks). Copy them into place:

```sh
git clone https://github.com/mxmgorin/dotfiles ~/Repos/dotfiles
cd ~/Repos/dotfiles

# back up whatever you have, then copy
for d in config/*/; do
    name=$(basename "$d")
    [ -e ~/.config/"$name" ] && mv ~/.config/"$name" ~/.config/"$name".bak
    cp -r "$d" ~/.config/"$name"
done

chmod +x ~/.config/scripts/*.sh ~/.config/scripts/*
```

Alacritty themes are kept as a separate repo (not vendored here):

```sh
git clone https://github.com/alacritty/alacritty-theme ~/.config/alacritty/themes
```

## Key bindings (Niri)

`Mod` = Super (Win) when logged in to Niri natively.

### Launch / lock / power
- `Mod+Space` / `Alt+Space` / `Mod+Return` — fuzzel app launcher (toggle)
- `Mod+T` — terminal (alacritty)
- `Super+Escape` — lock screen (hyprlock)
- `Mod+Shift+E` — wlogout power menu (toggle)
- `Mod+Shift+B` — turn off monitors
- `Mod+Shift+P` — power profile picker (toggle)

### System
- `Mod+P` — cycle power profile (deprecated — use `Mod+Shift+P`)
- `Mod+F7` / `Mod+F8` — brightness ±5%
- `XF86MonBrightnessUp/Down` — brightness ±5% (Fn keys)
- `Shift+XF86MonBrightnessUp/Down` — keyboard backlight ±20%
- `Mod+Shift+N` — toggle night light (gammastep)
- `Mod+Shift+O` — rotate focused screen portrait/landscape
- `Mod+Shift+Comma` (`<`) — pick audio output device
- `Mod+Shift+Period` (`>`) — pick microphone

### Window/workspace navigation
- See `config/niri/config.kdl` `binds {}` block — too many to list

### Idle behavior
- After 30 min idle → monitors power off (swayidle)
- Wake on mouse/keyboard
- Before sleep → screen locks

## Notable customisations

- **Waybar grouped pills**: connectivity (vpn+wifi), display (brightness+gammastep), audio (sink+mic), metrics (mem+cpu+temp), power (battery+profile) — each as a single visual block instead of separate icons.
- **Click-to-menu**: clicking the audio/microphone/power-profile icons opens a fuzzel selector showing human-readable device descriptions, not cryptic ALSA names.
- **Coloured indicators**: VPN green when connected, CPU/RAM yellow→red on high load, battery green/yellow/red by charge, power-profile colour-coded.
- **Fast brightness**: `change-brightness.sh` runs the external monitor's DDC/CI write in background and uses relative `setvcp ± N` to skip the slow read — keypress latency dropped from ~1 s to ~50 ms.
- **One-replacement notifications**: brightness, volume, audio device switch, and power profile all use `x-canonical-private-synchronous` hints so repeat key presses replace the existing toast instead of stacking.

## Layout

Compositor: **Niri** (scrollable tiling, Wayland-native)
Bar: **Waybar**
Launcher / menus: **fuzzel**
Lock: **hyprlock**
Idle: **swayidle**
Notifications: **dunst**
Terminal: **alacritty**
Shell: **fish**
