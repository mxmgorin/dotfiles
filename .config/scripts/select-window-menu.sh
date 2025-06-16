#!/bin/sh

window_list=$(niri msg --json windows)
name=$(echo $window_list | jq -r '.[] | ."title"' | fuzzel --dmenu -p "pick a window >  " -w 50)
id=$(echo $window_list | jq -r '.[] | ."title", ."id"' | grep "$name" -x -A 1 | grep "$name" -vx)

echo $id
echo $name

niri msg action focus-window --id $id
