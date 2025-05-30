#!/usr/bin/env bash

ps -u $USER -o pid,comm,%cpu,%mem | fuzzel --dmenu -p "Kill: " | awk '{print $1}' | xargs -r kill
