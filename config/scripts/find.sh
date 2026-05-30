#!/bin/sh

dir=$(fd -H | fuzzel -p "~/ >  " --dmenu)
if [ $? = "0" ]
then
	if [ -d "$dir" ]
	then
		thunar "$dir"
	else
		xdg-open "$dir"
	fi
else
	return 0
fi
