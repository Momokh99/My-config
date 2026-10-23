#!/usr/bin/env bash
# Wallpaper picker with cached thumbnails (wofi dmenu mode).
# Full-size wallpapers are 2-4 MB PNGs; showing them directly makes wofi
# decode ~60 MB every time it opens. Instead we cache ~20 KB previews.
WALL_DIR="$HOME/.config/hypr/wallpaper"
CACHE="${XDG_CACHE_HOME:-$HOME/.cache}/wallpaper-thumbs"
THUMB_SIZE=320

mkdir -p "$CACHE"

mapfile -t wallpapers < <(
    find -L "$WALL_DIR" -maxdepth 1 -type f \
        \( -name '*.png' -o -name '*.jpg' -o -name '*.jpeg' -o -name '*.webp' \) | sort
)
[ ${#wallpapers[@]} -eq 0 ] && exit 0

# Preview name includes the mtime: replacing an image invalidates its thumb.
thumb_for() {
    local wp="$1" base mtime
    base="$(basename "$wp")"
    mtime="$(stat -c %Y "$wp")"
    printf '%s/%s-%s.jpg' "$CACHE" "${base%.*}" "$mtime"
}

# Create one preview if needed and print "thumb<TAB>original".
generate() {
    local wp="$1" thumb tmp
    thumb="$(thumb_for "$wp")"
    if [ ! -f "$thumb" ]; then
        if command -v magick >/dev/null 2>&1; then
            tmp="$thumb.tmp.$$"
            if magick "$wp" -auto-orient -thumbnail "${THUMB_SIZE}x${THUMB_SIZE}^" \
                -gravity center -extent "${THUMB_SIZE}x${THUMB_SIZE}" \
                -strip -quality 82 "$tmp" 2>/dev/null; then
                mv -f "$tmp" "$thumb"
            else
                rm -f "$tmp"
                thumb="$wp" # fall back to the original if conversion fails
            fi
        else
            # No ImageMagick yet (before the next rebuild): use the original,
            # unless a cached preview from an earlier run is available.
            thumb="$wp"
        fi
    fi
    printf '%s\t%s\n' "$thumb" "$wp"
}
export -f thumb_for generate
export CACHE THUMB_SIZE

declare -A ORIGINAL
entries=""
while IFS=$'\t' read -r thumb wp; do
    ORIGINAL["$thumb"]="$wp"
    entries+=":img:${thumb}"$'\n'
done < <(
    printf '%s\0' "${wallpapers[@]}" |
        xargs -0 -P "$(nproc)" -n 1 bash -c 'generate "$1"' _
)

# Drop previews for wallpapers that were changed or deleted.
declare -A KEEP
for wp in "${wallpapers[@]}"; do KEEP["$(thumb_for "$wp")"]=1; done
for f in "$CACHE"/*.jpg; do
    [ -e "$f" ] || continue
    [[ -v KEEP["$f"] ]] || rm -f "$f"
done

chosen=$(printf '%s' "$entries" | wofi --dmenu -I \
    --conf "$HOME/.config/wofi-wallpaper/config" \
    --style "$HOME/.config/wofi-wallpaper/style.css")

[ -z "$chosen" ] && exit 0

thumb="${chosen#*:img:}"
selected="${ORIGINAL[$thumb]:-$thumb}"

exec "$HOME/.local/bin/set-theme" "$selected"
