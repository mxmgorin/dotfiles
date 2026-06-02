#!/bin/bash
# Запускает waybar после готовности niri и держит его живым.
# Решает гонку старта: spawn-at-startup дёргает waybar раньше,
# чем готовы выводы/IPC, он падает один раз и больше не поднимается.

# 1. Ждём не «IPC ответил», а пока появится РЕАЛЬНЫЙ выход.
#    Без внешнего монитора eDP-1 регистрируется на доли секунды позже,
#    чем поднимается IPC, и waybar успевает стартовать «в пустоту».
for _ in $(seq 1 50); do
    if niri msg outputs 2>/dev/null | grep -q '^Output '; then
        break
    fi
    sleep 0.2
done

# 2. Держим единственный экземпляр waybar и перезапускаем при падении.
pkill -x waybar 2>/dev/null
sleep 0.3
while true; do
    waybar
    sleep 1
done
