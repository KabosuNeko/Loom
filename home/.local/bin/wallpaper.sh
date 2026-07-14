#!/usr/bin/env bash
# wallpaper.sh — wallpaper picker & applier for dwm / X11
# Uses dmenu, feh, pywal, xrdb. Auto-updates ~/.xinitrc.
set -euo pipefail

# ─── Config ──────────────────────────────────────────────────────────────
WALLPAPER_DIR="${WALLPAPER_DIR:-$HOME/Pictures/Wallpapers}"
CACHE_DIR="$HOME/.cache/wallpaper"
CACHE_LAST="$CACHE_DIR/last"
XINITRC="$HOME/.xinitrc"

# Block markers for managed section in .xinitrc
BLOCK_START="# >>> wallpaper.sh managed >>>"
BLOCK_END="# <<< wallpaper.sh managed <<<"

# ─── Dependency check ────────────────────────────────────────────────────
# Đã đổi rofi thành dmenu
REQUIRED_DEPS=(dmenu feh wal awk sed find)
missing=()

for dep in "${REQUIRED_DEPS[@]}"; do
    command -v "$dep" &>/dev/null || missing+=("$dep")
done

if ((${#missing[@]})); then
    printf "ERROR: missing required dependencies: %s\n" "${missing[*]}" >&2
    exit 1
fi

# ─── Helpers ─────────────────────────────────────────────────────────────

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

# Apply wallpaper: feh → wal (templates + deploy hook)
apply_wallpaper() {
    local img="$1"

    if [[ ! -f "$img" ]]; then
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

# ─── .xinitrc management ────────────────────────────────────────────────
update_xinitrc() {
    local img="$1"

    [[ -f "$XINITRC" ]] || return 0

    local block
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
        local first_feh=true
        while IFS= read -r line; do
            if [[ "$line" =~ ^[[:space:]]*feh\ --bg-fill ]] && $first_feh; then
                printf '%s\n' "$block"
                first_feh=false
            elif [[ "$line" =~ ^[[:space:]]*wal\ -i ]]; then
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

# ─── Dmenu picker ────────────────────────────────────────────────────────
pick_wallpaper() {
    if [[ ! -d "$WALLPAPER_DIR" ]]; then
        printf "ERROR: wallpaper directory not found: %s\n" "$WALLPAPER_DIR" >&2
        exit 1
    fi

    local -a names=()
    while IFS= read -r -d '' f; do
        names+=("$(basename "$f")")
    done < <(find "$WALLPAPER_DIR" -maxdepth 1 -type f \
        \( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' \
           -o -iname '*.webp' -o -iname '*.bmp' \) -print0 | sort -z)

    if ((${#names[@]} == 0)); then
        printf "ERROR: no images found in %s\n" "$WALLPAPER_DIR" >&2
        exit 1
    fi
    local choice
    choice=$(printf '%s\n' "${names[@]}" | dmenu -i -c -l 10 -p "Wallpaper") || exit 0

    [[ -z "$choice" ]] && exit 0

    apply_wallpaper "$WALLPAPER_DIR/$choice"
}

# ─── Restore last wallpaper ─────────────────────────────────────────────
restore_wallpaper() {
    if [[ ! -f "$CACHE_LAST" ]]; then
        printf "ERROR: no cached wallpaper found at %s\n" "$CACHE_LAST" >&2
        exit 1
    fi

    local last
    last=$(<"$CACHE_LAST")
    apply_wallpaper "$last"
}

# ─── Main ────────────────────────────────────────────────────────────────
case "${1:-}" in
    --apply)
        [[ -z "${2:-}" ]] && { printf "ERROR: --apply requires a path\n" >&2; exit 1; }
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
