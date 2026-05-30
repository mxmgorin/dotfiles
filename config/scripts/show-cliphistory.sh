#!/bin/bash

pkill fuzzel || cliphist list | fuzzel --dmenu | cliphist decode | wl-copy
