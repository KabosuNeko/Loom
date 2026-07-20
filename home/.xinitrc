#!/bin/sh

dbus-update-activation-environment --all
eval "$(gnome-keyring-daemon --start --components=secrets)"

if [ -d /etc/X11/xinit/xinitrc.d ]; then
    for f in /etc/X11/xinit/xinitrc.d/?*.sh; do
        [ -x "$f" ] && . "$f"
    done
    unset f
fi

# >>> wallpaper.sh managed >>>
feh --bg-fill "/home/mibanh/Pictures/Wallpapers/sunset.jpg" &
wal -n -o "$HOME/.config/wal/deploy.sh" -i "/home/mibanh/Pictures/Wallpapers/sunset.jpg"
# <<< wallpaper.sh managed <<<

xrdb -merge "$CACHE/colors.Xresources"
[ -f "$CACHE/xrdb_extra" ] && xrdb -merge "$CACHE/xrdb_extra"

picom &
dunst &
slstatus &
clipmenud &
fcitx5 -d &
redshift &
lxqt-policykit-agent &
xautolock -time 10 -notify 10 -notifier "notify-send 'Locking in 10s'" -locker "slock" -detectsleep &
xset r rate 200 35

exec dwm
