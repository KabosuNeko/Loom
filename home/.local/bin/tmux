#!/bin/sh
set -eu

sessions="$(tmux list-sessions -F '#S' 2>/dev/null || true)"
[ -n "${sessions}" ] || exit 0

dmenu_pick_session() {
    dmenu -i -c -l 10 -p 'tmux sessions:'
}

chosen="$(printf '%s\n' "$sessions" | dmenu_pick_session)"

[ -n "$chosen" ] || exit 0

if [ "${TMUX-}" ]; then
  exec tmux switch-client -t "${chosen}"
fi

client_tty="$(
  tmux list-clients -F '#{client_tty} #{client_termname}' 2>/dev/null \
  | awk '$2 ~ /^st/ { print $1; exit }' || true
)"

if [ -n "${client_tty}" ]; then
  tmux switch-client -c "${client_tty}" -t "${chosen}"
  exit 0
fi

exec st -e tmux attach -t "${chosen}"
