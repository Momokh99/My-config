#!/usr/bin/env bash
# Wallpaper picker with cached thumbnails (wofi dmenu mode).
# The images are stored compressed as WebP in hypr/wallpapers.tar.gz; showing
# full-size files directly makes wofi decode ~5 MB every time it opens, so we
# cache ~20 KB previews instead.
WALL_DIR="$HOME/.config/hypr/wallpaper"
CACHE="${XDG_CACHE_HOME:-$HOME/.cache}/wallpaper-thumbs"
THUMB_WIDTH=320
THUMB_HEIGHT=200

mkdir -p "$CACHE" "$WALL_DIR"

scan_wallpapers() {
    find -L "$WALL_DIR" -maxdepth 1 -type f \
        \( -name '*.png' -o -name '*.jpg' -o -name '*.jpeg' -o -name '*.webp' \) | sort
}

mapfile -t wallpapers < <(scan_wallpapers)

# The images live compressed in git; extract them on first use.
if [ ${#wallpapers[@]} -eq 0 ] && command -v wallpaper-pack >/dev/null 2>&1; then
    wallpaper-pack sync >/dev/null 2>&1 || true
    mapfile -t wallpapers < <(scan_wallpapers)
fi

if [ ${#wallpapers[@]} -eq 0 ]; then
    command -v notify-send >/dev/null 2>&1 &&
        notify-send -a wallpaper "No wallpapers" \
            "Run: wallpaper-pack sync" >/dev/null 2>&1
    exit 0
fi

# Preview name includes the mtime: replacing an image invalidates its thumb.
thumb_for() {
    local wp="$1" base mtime
    base="$(basename "$wp")"
    mtime="$(stat -c %Y "$wp")"
    printf '%s/%s-%s-%sx%s.jpg' "$CACHE" "${base%.*}" "$mtime" \
        "$THUMB_WIDTH" "$THUMB_HEIGHT"
}

# Create one preview if needed and print "thumb<TAB>original".
generate() {
    local wp="$1" thumb tmp
    thumb="$(thumb_for "$wp")"
    if [ ! -f "$thumb" ]; then
        if command -v magick >/dev/null 2>&1; then
            tmp="$thumb.tmp.$$"
            if magick "$wp" -auto-orient -thumbnail "${THUMB_WIDTH}x${THUMB_HEIGHT}^" \
                -gravity center -extent "${THUMB_WIDTH}x${THUMB_HEIGHT}" \
                -strip -quality 82 "jpg:$tmp" 2>/dev/null; then
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
export CACHE THUMB_WIDTH THUMB_HEIGHT

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
    --style "$HOME/.config/wofi-wallpaper/style.css" \
    --color "$HOME/.config/wofi-wallpaper/colors.css")

[ -z "$chosen" ] && exit 0

thumb="${chosen#*:img:}"
selected="${ORIGINAL[$thumb]:-$thumb}"

exec "$HOME/.local/bin/set-theme" "$selected"
