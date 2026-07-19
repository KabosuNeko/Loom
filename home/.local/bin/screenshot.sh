#!/usr/bin/env bash
set -euo pipefail
export DISPLAY="${DISPLAY:-:0}"

for cmd in xclip import notify-send; do
    command -v "$cmd" &>/dev/null || { echo "Missing: $cmd" >&2; exit 1; }
done

OUTDIR="${2:-$HOME/Pictures/Screenshots}"
mkdir -p "$OUTDIR"
FILE="$OUTDIR/$(date +%Y%m%d_%H%M%S).png"

post(){
    pkill -f clipmenud || true
    xclip -selection clipboard -t image/png -i "$FILE" && \
    notify-send -i "$FILE" "Screenshot Saved" "$(basename "$FILE")"
    ( sleep 1 && clipmenud ) & disown
}
case "${1:-}" in
    full)
        import -window root "$FILE" && post
        ;;
    *)
        import "$FILE" && post
        ;;
esac
