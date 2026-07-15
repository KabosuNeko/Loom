#!/usr/bin/env bash

OPTIONS=" Lock\n󰒲 Suspend\n󰤄 Hibernate\n Reboot\n⏻ PowerOff\n󰍃 LogOut"
SELECTED=$(printf '%b' "$OPTIONS" | dmenu -i -c -l 6 -p "Power Menu:")
ACTION=$(echo "$SELECTED" | awk '{print $2}')

case "$ACTION" in
    Lock)
        slock
        ;;
    Suspend)
        systemctl suspend
        ;;
    Hibernate)
        systemctl hibernate
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
