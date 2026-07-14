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
    if [[ "${WATERMARK:-}" == "1" ]]; then
        command -v magick &>/dev/null || { echo "Missing: magick" >&2; exit 1; }
        magick "$FILE" \
            -gravity "${WATERMARK_POS:-southeast}" \
            -pointsize "${WATERMARK_SIZE:-28}" \
            -fill white -undercolor "${WATERMARK_BG:-#00000080}" \
            -annotate +20+20 "${WATERMARK_TEXT:-$(date '+%Y-%m-%d %H:%M')}" \
            "$FILE"
    fi

    xclip -selection clipboard -t image/png -i "$FILE" && \
    notify-send -i "$FILE" "Screenshot Saved" "$(basename "$FILE")"
}

case "${1:-}" in
    full)
        import -window root "$FILE" && post
        ;;
    *)
        import "$FILE" && post
        ;;
esac
