#!/bin/sh
set -eu

terminal="st"

configs="$(ls -1d "$HOME"/Projects/*/ 2>/dev/null | xargs -n1 basename)"
[ -n "$configs" ] || exit 0

chosen="$(printf '%s\n' $configs | dmenu -i -c -l 10 -p 'Projects:')"
[ -n "$chosen" ] || exit 0
dir="$HOME/Projects/$chosen"

exec $terminal -e tmux new-session -As "$chosen" -c "$dir"
