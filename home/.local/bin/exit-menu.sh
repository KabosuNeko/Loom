#!/usr/bin/env bash

# Exit Menu using dmenu

OPTIONS=" Lock\n󰒲 Suspend\n Reboot\n⏻ PowerOff\n󰍃 LogOut"

SELECTED=$(printf '%b' "$OPTIONS" | dmenu -i -c -l 5 -p "Power Menu:")
ACTION=$(echo "$SELECTED" | awk '{print $2}')

case "$ACTION" in
    Lock)
        slock
        ;;
    Suspend)
        systemctl suspend
        ;;
    Reboot)
        systemctl reboot
        ;;
    PowerOff)
        systemctl poweroff
        ;;
    LogOut)
        pkill dwm
        ;;
esac
