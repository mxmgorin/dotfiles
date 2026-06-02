#!/bin/bash
# /* ---- 💫 https://github.com/JaKooLit 💫 ---- */  ##
# Scripts for volume controls for audio and mic

iDIR="$HOME/.config/swaync/icons"
sDIR="$HOME/.config/hypr/scripts"

get_default_sink_description() {
    local default_sink
    default_sink=$(pactl info | grep "Default Sink" | cut -d ':' -f2 | xargs)

    pactl list sinks | awk -v sink="$default_sink" '
        $0 ~ "Name: "sink { show=1 }
        show && /Description:/ {
            gsub(/^[[:space:]]*Description: /, "", $0)
            print $0
            exit
        }'
}

get_default_source_description() {
    local default_source
    default_source=$(pactl info | grep "Default Source" | cut -d ':' -f2 | xargs)

    pactl list sources | awk -v src="$default_source" '
        $0 ~ "Name: "src { show=1 }
        show && /Description:/ {
            gsub(/^[[:space:]]*Description: /, "", $0)
            print $0
            exit
        }'
}

get_volume() {
    volume=$(pamixer --get-volume)
    if [[ "$volume" -eq "0" ]]; then
        echo "Muted"
    else
        echo "$volume%"
    fi
}

get_icon() {
    current=$(get_volume)
    if [[ "$current" == "Muted" ]]; then
        echo "$iDIR/volume-mute.png"
    elif [[ "${current%\%}" -le 30 ]]; then
        echo "$iDIR/volume-low.png"
    elif [[ "${current%\%}" -le 60 ]]; then
        echo "$iDIR/volume-mid.png"
    else
        echo "$iDIR/volume-high.png"
    fi
}

notify_user() {
    desc=$(get_default_sink_description)
    if [[ "$(get_volume)" == "Muted" ]]; then
        notify-send -a "system-script" -e  -h string:x-canonical-private-synchronous:volume_notif -u low -i "$(get_icon)" " Volume:" " $desc: Muted"
    else
        notify-send -a "system-script" -e  -h int:value:"$(get_volume | sed 's/%//')" -h string:x-canonical-private-synchronous:volume_notif -u low -i "$(get_icon)" " Volume Level:" " $desc: $(get_volume)" &&
        "$sDIR/Sounds.sh" --volume
    fi
}

# --- Управление громкостью сразу у ВСЕХ sink'ов ---------------------------
# Раньше pamixer крутил только дефолтный sink (а им стоит loopback snd_aloop),
# поэтому менялся «не тот» выход. Теперь проходим по всем sink'ам.

all_sink_ids() {
    pactl list short sinks | awk '{print $1}'
}

# Громкость sink'а в процентах (первое число с %).
sink_volume_pct() {
    pactl get-sink-volume "$1" 2>/dev/null | grep -oP '\d+(?=%)' | head -1
}

inc_volume() {
    for s in $(all_sink_ids); do
        # снимаем mute и поднимаем, не превышая 150% (boost-лимит)
        pactl set-sink-mute "$s" 0 2>/dev/null
        cur=$(sink_volume_pct "$s")
        if [ "${cur:-0}" -lt 150 ]; then
            pactl set-sink-volume "$s" +5% 2>/dev/null
        fi
    done
    notify_user
}

dec_volume() {
    for s in $(all_sink_ids); do
        pactl set-sink-volume "$s" -5% 2>/dev/null
    done
    notify_user
}

toggle_mute() {
    desc=$(get_default_sink_description)

    # Целевое состояние определяем по дефолтному sink, применяем ко всем.
    if [ "$(pamixer --get-mute)" == "true" ]; then
        new=0   # был muted → включаем всё
    else
        new=1   # был активен → глушим всё
    fi

    for s in $(all_sink_ids); do
        pactl set-sink-mute "$s" "$new" 2>/dev/null
    done

    if [ "$new" == "1" ]; then
        notify-send -a "system-script" -e -u low -i "$iDIR/volume-mute.png" "Volume Level:" " Switched OFF (all sinks)"
    else
        notify-send -a "system-script" -e -u low -i "$(get_icon)" " Volume Level:" " Switched ON (all sinks)"
    fi
}

toggle_mic() {
    desc=$(get_default_source_description)

	if [ "$(pamixer --default-source --get-mute)" == "false" ]; then
		pamixer --default-source -m && notify-send -a "system-script" -e  -u low -i "$iDIR/microphone-mute.png" " Microphone:" " Switched OFF ($desc)"
	elif [ "$(pamixer --default-source --get-mute)" == "true" ]; then
		pamixer -u --default-source u && notify-send -a "system-script" -e  -u low -i "$iDIR/microphone.png" " Microphone:" " Switched ON ($desc)"
	fi
}

get_mic_icon() {
    current=$(pamixer --default-source --get-volume)
    if [[ "$current" -eq "0" ]]; then
        echo "$iDIR/microphone-mute.png"
    else
        echo "$iDIR/microphone.png"
    fi
}

get_mic_volume() {
    volume=$(pamixer --default-source --get-volume)
    if [[ "$volume" -eq "0" ]]; then
        echo "Muted"
    else
        echo "$volume%"
    fi
}

notify_mic_user() {
    desc=$(get_default_source_description)
    volume=$(get_mic_volume)
    icon=$(get_mic_icon)
    notify-send -a "system-script" -e  -h int:value:"$volume" -h "string:x-canonical-private-synchronous:volume_notif" -u low -i "$icon"  " Mic Level:" " $desc: $volume"
}

inc_mic_volume() {
    if [ "$(pamixer --default-source --get-mute)" == "true" ]; then
        toggle_mic
    else
        pamixer --default-source -i 5 && notify_mic_user
    fi
}

dec_mic_volume() {
    if [ "$(pamixer --default-source --get-mute)" == "true" ]; then
        toggle-mic
    else
        pamixer --default-source -d 5 && notify_mic_user
    fi
}

if [[ "$1" == "--get" ]]; then
	get_volume
elif [[ "$1" == "--inc" ]]; then
	inc_volume
elif [[ "$1" == "--dec" ]]; then
	dec_volume
elif [[ "$1" == "--toggle" ]]; then
	toggle_mute
elif [[ "$1" == "--toggle-mic" ]]; then
	toggle_mic
elif [[ "$1" == "--get-icon" ]]; then
	get_icon
elif [[ "$1" == "--get-mic-icon" ]]; then
	get_mic_icon
elif [[ "$1" == "--mic-inc" ]]; then
	inc_mic_volume
elif [[ "$1" == "--mic-dec" ]]; then
	dec_mic_volume
else
	get_volume
fi
