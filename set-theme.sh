#!/usr/bin/env bash
# set-theme.sh — set the wallpaper with a fade and regenerate matching colours.
# Usage: set-theme.sh <image> | set-theme.sh --restore
set -uo pipefail

TRANSITION_DURATION="${TRANSITION_DURATION:-1.5}"
STATE="${XDG_CACHE_HOME:-$HOME/.cache}/current-wallpaper"

# Usually launched from a keybind or wofi, where stderr is invisible.
die() {
    echo "set-theme: $*" >&2
    command -v notify-send >/dev/null 2>&1 &&
        notify-send -a set-theme "Theme update failed" "$*" >/dev/null 2>&1
    exit 1
}

# The documented default, or any extracted wallpaper when it is missing.
default_wallpaper() {
    local dir="$HOME/.config/hypr/wallpaper" f
    for f in "$dir/wallpaper-26.png" \
        "$dir"/*.png "$dir"/*.jpg "$dir"/*.jpeg "$dir"/*.webp; do
        [ -f "$f" ] && { printf '%s\n' "$f"; return 0; }
    done
    return 1
}

if [ "${1:-}" = "--restore" ]; then
    # Restore the last wallpaper, or a sane default on first login.
    if [ -r "$STATE" ] && [ -f "$(cat "$STATE")" ]; then
        WALLPAPER="$(cat "$STATE")"
    else
        WALLPAPER="$(default_wallpaper)"
        [ -n "$WALLPAPER" ] || die "no wallpaper found; run wallpaper-pack sync"
    fi
elif [ -n "${1:-}" ] && [ -f "${1:-}" ]; then
    WALLPAPER="$(realpath "$1")"
else
    echo "Usage: set-theme.sh <image> | set-theme.sh --restore" >&2
    exit 1
fi

command -v awww >/dev/null 2>&1 || die "awww is not installed"
command -v matugen >/dev/null 2>&1 || die "matugen is not installed"

# The daemon is usually started by Hyprland's autostart; make this script
# self-sufficient for the first run or after a crash.
if ! awww query >/dev/null 2>&1; then
    awww-daemon >/dev/null 2>&1 &
    for _ in $(seq 1 100); do
        awww query >/dev/null 2>&1 && break
        sleep 0.1
    done
fi
awww query >/dev/null 2>&1 || die "awww-daemon did not start"

awww img "$WALLPAPER" \
    --transition-type fade \
    --transition-duration "$TRANSITION_DURATION" \
    --transition-fps 60 \
    --transition-bezier .43,1.19,1,.4 ||
    die "could not apply wallpaper $WALLPAPER"

# Remember it (only now that it actually applied) so the next login restores
# the same wallpaper.
mkdir -p "$(dirname "$STATE")"
printf '%s\n' "$WALLPAPER" > "$STATE"

# Regenerate the palette; matugen's post-hooks update Waybar, borders, etc.
# Honour the target selection written by setup.sh, if one exists.
STATE_CFG="${XDG_STATE_HOME:-$HOME/.local/state}/matugen/selected.toml"
if [ -f "$STATE_CFG" ]; then
    matugen image "$WALLPAPER" -c "$STATE_CFG" ||
        die "palette regeneration failed (the wallpaper was applied)"
else
    matugen image "$WALLPAPER" ||
        die "palette regeneration failed (the wallpaper was applied)"
fi
