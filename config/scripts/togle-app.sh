#!/bin/bash

APP_NAME="$1"

if pgrep -x "$APP_NAME" > /dev/null
then
    pkill -x "$APP_NAME"
else
    alacritty --title waybar_$APP_NAME -e $APP_NAME
fi
