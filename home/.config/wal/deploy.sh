#!/bin/sh
# Post-processing hook for pywal — deploys templates to their real locations.
# Called via: wal -n -o "$HOME/.config/wal/deploy.sh" -i <image>

mkdir -p "$HOME/.config/dunst"

CACHE="${cache_dir:-$HOME/.cache/wal}"

[ -f "$CACHE/dunstrc" ] && cp "$CACHE/dunstrc" "$HOME/.config/dunst/dunstrc" && killall dunst; dunst &

xrdb -merge "$CACHE/colors.Xresources"
[ -f "$CACHE/xrdb_extra" ] && xrdb -merge "$CACHE/xrdb_extra"

if pidof -x dwm >/dev/null; then
    command -v xdotool >/dev/null 2>&1 && xdotool key --clearmodifiers super+F5
fi
