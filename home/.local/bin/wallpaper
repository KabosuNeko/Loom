#!/bin/sh
set -eu

WALLPAPER_DIR="${WALLPAPER_DIR:-$HOME/Pictures/Wallpapers}"
CACHE_DIR="$HOME/.cache/wallpaper"
CACHE_LAST="$CACHE_DIR/last"
XINITRC="$HOME/.xinitrc"

BLOCK_START="# >>> wallpaper.sh managed >>>"
BLOCK_END="# <<< wallpaper.sh managed <<<"

missing=''
for dep in dmenu feh wal awk sed find; do
    command -v "$dep" >/dev/null 2>&1 || missing="$missing $dep"
done

if [ -n "$missing" ]; then
    printf "ERROR: missing required dependencies:%s\n" "$missing" >&2
    exit 1
fi

usage() {
    cat <<EOF
Usage: $(basename "$0") [OPTION]

Options:
  (none)              Open dmenu picker to select a wallpaper
  --apply <path>      Apply the given image directly
  --restore           Re-apply the last used wallpaper
  --help              Show this help message

Wallpaper directory: $WALLPAPER_DIR
Cache file:          $CACHE_LAST
EOF
    exit 0
}

apply_wallpaper() {
    img="$1"

    if [ ! -f "$img" ]; then
        printf "ERROR: file not found: %s\n" "$img" >&2
        exit 1
    fi

    img="$(realpath "$img")"

    feh --bg-fill "$img"

    wal -n -o "$HOME/.config/wal/deploy.sh" -i "$img"

    mkdir -p "$CACHE_DIR"
    printf '%s\n' "$img" > "$CACHE_LAST"

    update_xinitrc "$img"

    printf "Wallpaper applied: %s\n" "$img"
}

update_xinitrc() {
    img="$1"

    [ -f "$XINITRC" ] || return 0

    block="$(printf '%s\n%s\n%s\n%s' \
        "$BLOCK_START" \
        "feh --bg-fill \"$img\" &" \
        "wal -n -o \"\$HOME/.config/wal/deploy.sh\" -i \"$img\"" \
        "$BLOCK_END")"

    if grep -qF "$BLOCK_START" "$XINITRC"; then
        awk -v start="$BLOCK_START" -v end_mark="$BLOCK_END" -v new="$block" '
            $0 == start { skip=1; next }
            skip && $0 == end_mark { skip=0; print new; next }
            skip { next }
            { print }
        ' "$XINITRC" > "$XINITRC.tmp"
        mv -- "$XINITRC.tmp" "$XINITRC"
    elif grep -qE '^[[:space:]]*(feh --bg-fill|wal -i)' "$XINITRC"; then
        first_feh='true'
        while IFS= read -r line; do
            if echo "$line" | grep -q '^[[:space:]]*feh --bg-fill' && [ "$first_feh" = 'true' ]; then
                printf '%s\n' "$block"
                first_feh='false'
            elif echo "$line" | grep -q '^[[:space:]]*wal -i'; then
                continue
            else
                printf '%s\n' "$line"
            fi
        done < "$XINITRC" > "$XINITRC.tmp"
        mv -- "$XINITRC.tmp" "$XINITRC"
    else
        awk -v block="$block" '
            /^[[:space:]]*exec[[:space:]].*dwm/ {
                print block
                print ""
            }
            { print }
        ' "$XINITRC" > "$XINITRC.tmp"
        mv -- "$XINITRC.tmp" "$XINITRC"
    fi
}

pick_wallpaper() {
    if [ ! -d "$WALLPAPER_DIR" ]; then
        printf "ERROR: wallpaper directory not found: %s\n" "$WALLPAPER_DIR" >&2
        exit 1
    fi

    names=$(find "$WALLPAPER_DIR" -maxdepth 1 -type f \
        \( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' \
           -o -iname '*.webp' -o -iname '*.bmp' \) 2>/dev/null | sort | sed 's|.*/||')

    if [ -z "$names" ]; then
        printf "ERROR: no images found in %s\n" "$WALLPAPER_DIR" >&2
        exit 1
    fi

    choice=$(printf '%s\n' "$names" | dmenu -i -c -l 10 -p "Wallpaper") || exit 0

    [ -z "$choice" ] && exit 0

    apply_wallpaper "$WALLPAPER_DIR/$choice"
}

restore_wallpaper() {
    if [ ! -f "$CACHE_LAST" ]; then
        printf "ERROR: no cached wallpaper found at %s\n" "$CACHE_LAST" >&2
        exit 1
    fi

    last=$(cat "$CACHE_LAST")
    apply_wallpaper "$last"
}

case "${1:-}" in
    --apply)
        [ -z "${2:-}" ] && { printf "ERROR: --apply requires a path\n" >&2; exit 1; }
        apply_wallpaper "$2"
        ;;
    --restore)
        restore_wallpaper
        ;;
    --help|-h)
        usage
        ;;
    "")
        pick_wallpaper
        ;;
    *)
        printf "Unknown option: %s\n" "$1" >&2
        usage
        ;;
esac
