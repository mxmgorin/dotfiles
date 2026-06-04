# ASUS ROG Strix G512 — фикс встроенных динамиков (Realtek ALC294)

## Проблема

На ноутбуке **ASUS ROG Strix G512LV** (кодек Realtek **ALC294**, SSID `1043:1f21`)
нет звука из встроенных динамиков, при этом наушники (3.5 мм jack) и HDMI работают.

Причина: внутренний усилитель динамиков включается двумя «секретными» COEF-записями
кодека, которые ASUS прописывает в Windows-драйвере. Ядро Linux для этого конкретного
SSID их не применяет (в `dmesg`: `ALC294: picked fixup  (pin match)` — пустой фиксап),
поэтому динамики молчат.

Включается так:

| COEF index | Значение |
|------------|----------|
| `0x0f`     | `0x7778` |
| `0x40`     | `0x0800` |

Ровно это делает апстрим-фиксап ядра `ALC294_FIXUP_ASUS_G512_SPK`. Здесь те же записи
применяются из userspace через `hda-verb` при загрузке и после выхода из сна.

## Зависимости

```bash
sudo pacman -S --needed alsa-tools   # даёт hda-verb
```

## Установка

```bash
sudo install -m755 asus-g512-speaker-fix.sh       /usr/local/bin/asus-g512-speaker-fix.sh
sudo install -m755 asus-g512-speaker-fix-sleep.sh /usr/lib/systemd/system-sleep/asus-g512-speaker-fix
sudo install -m644 asus-g512-speaker-fix.service  /etc/systemd/system/asus-g512-speaker-fix.service
sudo systemctl daemon-reload
sudo systemctl enable --now asus-g512-speaker-fix.service
```

Проверка:

```bash
systemctl status asus-g512-speaker-fix.service
speaker-test -D pulse -c2 -twav -l1
```

## Файлы

- `asus-g512-speaker-fix.sh` — находит карту ALC294 и шлёт COEF-verb'ы (`/usr/local/bin/`).
- `asus-g512-speaker-fix.service` — systemd-сервис, применяет фикс при загрузке.
- `asus-g512-speaker-fix-sleep.sh` — system-sleep hook, повторяет фикс после resume
  (после сна COEF сбрасывается).

## Откат

```bash
sudo systemctl disable --now asus-g512-speaker-fix.service
sudo rm /etc/systemd/system/asus-g512-speaker-fix.service \
        /usr/local/bin/asus-g512-speaker-fix.sh \
        /usr/lib/systemd/system-sleep/asus-g512-speaker-fix
sudo systemctl daemon-reload
```

## Альтернатива

Встроить фиксап прямо в драйвер через DKMS: см.
<https://github.com/supg/linux-asus-g512-speaker-fix> (фиксап `ALC294_FIXUP_ASUS_G512_SPK`,
SSID `0x10431f21`). systemd-вариант проще и не требует пересборки при обновлении ядра.
