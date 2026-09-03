#!/usr/bin/env bash
# set-theme.sh — Set wallpaper and generate matching colors with matugen
# Usage: set-theme.sh /path/to/image.png [monitor]

if [ -z "$1" ]; then
    echo "Usage: set-theme.sh /path/to/image.png [monitor]"
    exit 1
fi

WALLPAPER="$(realpath "$1")"
MONITOR="${2:-}"

# 1. Preload image into hyprpaper RAM
hyprctl hyprpaper preload "$WALLPAPER"

# 2. Extract colors & update config templates with matugen
matugen image "$WALLPAPER"

# 3. Apply the wallpaper to the specified monitor or all monitors
if [ -n "$MONITOR" ]; then
    hyprctl hyprpaper wallpaper "$MONITOR,$WALLPAPER"
else
    MONITORS=$(hyprctl monitors -j | grep -o '"name": *"[^"]*"' | cut -d'"' -f4)
    for mon in $MONITORS; do
        hyprctl hyprpaper wallpaper "$mon,$WALLPAPER"
    done
fi

# 4. Unload unused preloaded wallpapers to free RAM
hyprctl hyprpaper unload all
