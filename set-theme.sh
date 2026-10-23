#!/usr/bin/env bash
# set-theme.sh — set the wallpaper with a fade and regenerate matching colours.
# Usage: set-theme.sh <image> | set-theme.sh --restore
set -u

TRANSITION_DURATION="${TRANSITION_DURATION:-1.5}"
STATE="${XDG_CACHE_HOME:-$HOME/.cache}/current-wallpaper"

if [ "${1:-}" = "--restore" ]; then
    # Restore the last wallpaper, or a sane default on first login.
    if [ -r "$STATE" ] && [ -f "$(cat "$STATE")" ]; then
        WALLPAPER="$(cat "$STATE")"
    else
        WALLPAPER="$HOME/.config/hypr/wallpaper/wallpaper-26.png"
    fi
elif [ -n "${1:-}" ] && [ -f "${1:-}" ]; then
    WALLPAPER="$(realpath "$1")"
else
    echo "Usage: set-theme.sh <image> | set-theme.sh --restore" >&2
    exit 1
fi

# The daemon is usually started by Hyprland's autostart; make this script
# self-sufficient for the first run or after a crash.
if ! awww query >/dev/null 2>&1; then
    awww-daemon >/dev/null 2>&1 &
    for _ in $(seq 1 100); do
        awww query >/dev/null 2>&1 && break
        sleep 0.1
    done
fi

awww img "$WALLPAPER" \
    --transition-type fade \
    --transition-duration "$TRANSITION_DURATION" \
    --transition-fps 60 \
    --transition-bezier .43,1.19,1,.4

# Remember it so the next login restores the same wallpaper.
mkdir -p "$(dirname "$STATE")"
printf '%s\n' "$WALLPAPER" > "$STATE"

# Regenerate the palette; matugen's post-hooks update Waybar, borders, etc.
matugen image "$WALLPAPER"
