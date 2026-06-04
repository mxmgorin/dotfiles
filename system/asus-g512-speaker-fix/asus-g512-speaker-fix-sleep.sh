#!/bin/bash
# Re-apply ALC294 speaker COEF after resume from suspend/hibernate.
case "$1" in
    post)
        /usr/local/bin/asus-g512-speaker-fix.sh
        ;;
esac
