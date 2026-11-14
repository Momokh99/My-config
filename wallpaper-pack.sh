#!/usr/bin/env bash
# wallpaper-pack.sh — keep wallpapers compressed in git, extract them on the host.
#
#   wallpaper-pack build   convert the images in hypr/wallpaper/ and rewrite the pack
#   wallpaper-pack sync    extract the pack into hypr/wallpaper/ (skip when current)
#   wallpaper-pack list    print the images stored in the pack
#
# The pack lives in git; hypr/wallpaper/ is ignored and rebuilt from it.
set -uo pipefail

SELF=$(readlink -f "${BASH_SOURCE[0]}")
REPO=${DOTS_DIR:-$(dirname "$SELF")}
PACK="$REPO/hypr/wallpapers.tar.gz"
DEST="$REPO/hypr/wallpaper"
CACHE="${XDG_CACHE_HOME:-$HOME/.cache}/wallpaper-pack"
STAMP="$CACHE/pack.sha256"
MANIFEST="$CACHE/manifest"

# The README links to this screenshot, so it is not a wallpaper and stays in git.
EXCLUDE=(20260508_14h01m35s_grim.png)
# Kept as PNG so set-theme.sh's fallback and the documented example keep working.
KEEP_AS_IS=(wallpaper-26.png)
QUALITY=90

die() {
    echo "wallpaper-pack: $*" >&2
    exit 1
}

usage() {
    cat <<'EOF'
Usage: wallpaper-pack build | sync [--force] | list

  build        Re-encode hypr/wallpaper/ (WebP q90) and rewrite hypr/wallpapers.tar.gz
  sync         Extract the pack into hypr/wallpaper/; --force ignores the stamp
  list         List the images stored in the pack
EOF
}

sources() {
    [ -d "$DEST" ] || return 0
    find -L "$DEST" -maxdepth 1 -type f \
        \( -name '*.png' -o -name '*.jpg' -o -name '*.jpeg' -o -name '*.webp' \) \
        -printf '%f\n' | sort
}

pack_entries() {
    [ -f "$PACK" ] || die "pack not found: $PACK"
    tar -tzf "$PACK" | sed -e 's|^\./||' -e '/^$/d' -e '/\/$/d'
}

matches() {
    local name=$1 entry
    shift
    for entry in "$@"; do
        [ "$name" = "$entry" ] && return 0
    done
    return 1
}

cmd_build() {
    command -v magick >/dev/null 2>&1 || die "ImageMagick (magick) is required to build the pack"
    [ -d "$DEST" ] || die "missing wallpaper directory: $DEST"

    BUILD_TMP=$(mktemp -d "${TMPDIR:-/tmp}/wallpaper-pack.XXXXXX") || die "could not create a temp dir"
    trap 'rm -rf "$BUILD_TMP"' EXIT
    local tmp=$BUILD_TMP

    local name out count=0
    while IFS= read -r name; do
        [ -n "$name" ] || continue
        if matches "$name" "${EXCLUDE[@]}"; then continue; fi

        if matches "$name" "${KEEP_AS_IS[@]}"; then
            cp -p "$DEST/$name" "$tmp/$name" || die "could not copy $name"
            count=$((count + 1))
            continue
        fi

        out="${name%.*}.webp"
        if [[ $name == *.webp ]]; then
            cp -p "$DEST/$name" "$tmp/$out" || die "could not copy $name"
        else
            # Flat/illustrated art compresses far better losslessly than a lossy
            # encode, and lossy WebP can smear sharp edges. Try both and keep
            # the smaller file: exact for art, compact for photographs.
            magick "$DEST/$name" -auto-orient -strip -quality "$QUALITY" \
                -define webp:method=6 "$tmp/lossy.webp" || die "conversion failed: $name"
            magick "$DEST/$name" -auto-orient -strip -define webp:lossless=true \
                -define webp:method=6 "$tmp/lossless.webp" || die "conversion failed: $name"
            if [ "$(stat -c %s "$tmp/lossless.webp")" -le "$(stat -c %s "$tmp/lossy.webp")" ]; then
                mv -f "$tmp/lossless.webp" "$tmp/$out"
            else
                mv -f "$tmp/lossy.webp" "$tmp/$out"
            fi
            rm -f "$tmp/lossless.webp" "$tmp/lossy.webp"
        fi
        count=$((count + 1))
    done < <(sources)

    [ "$count" -gt 0 ] || die "no wallpapers found in $DEST"

    tar -czf "$PACK.tmp" -C "$tmp" . || die "could not write $PACK"
    mv -f "$PACK.tmp" "$PACK" || die "could not replace $PACK"
    printf 'built %s: %d images, %s\n' "$PACK" "$count" "$(du -h "$PACK" | cut -f1)"
}

cmd_sync() {
    local force=0
    [ "${1:-}" = "--force" ] && force=1
    [ -f "$PACK" ] || die "pack not found: $PACK"

    mkdir -p "$DEST" "$CACHE" || die "could not create $DEST"

    local sum
    sum=$(sha256sum "$PACK" | cut -d' ' -f1) || die "could not hash $PACK"

    if [ "$force" -eq 0 ] && [ -f "$STAMP" ] && [ -f "$MANIFEST" ] &&
        [ "$(cat "$STAMP")" = "$sum" ]; then
        local name missing=0
        while IFS= read -r name; do
            [ -n "$name" ] || continue
            if [ ! -f "$DEST/$name" ]; then
                missing=1
                break
            fi
        done < "$MANIFEST"
        if [ "$missing" -eq 0 ]; then
            echo "wallpapers are up to date"
            return 0
        fi
    fi

    local entries
    entries=$(pack_entries) || exit 1

    # Drop files the previous pack owned but the current one no longer ships.
    if [ -f "$MANIFEST" ]; then
        local name
        while IFS= read -r name; do
            [ -n "$name" ] || continue
            printf '%s\n' "$entries" | grep -Fxq "$name" || rm -f "$DEST/$name"
        done < "$MANIFEST"
    fi

    tar -xzf "$PACK" -C "$DEST" || die "could not extract $PACK"
    printf '%s\n' "$entries" > "$MANIFEST"
    printf '%s\n' "$sum" > "$STAMP"
    printf 'extracted %d wallpapers into %s\n' "$(printf '%s\n' "$entries" | wc -l)" "$DEST"
}

cmd_list() {
    pack_entries
}

case ${1:-} in
    build) cmd_build ;;
    sync) shift; cmd_sync "$@" ;;
    list) cmd_list ;;
    -h | --help | help) usage ;;
    *) usage >&2; exit 2 ;;
esac
