#!/usr/bin/env bash
# Matugen wallpaper hook daemon
# Detects wallpaper changes from hyprpaper rotation and runs matugen
LAST_WALLPAPER=""

while true; do
    CURRENT=$(hyprctl hyprpaper listactive 2>/dev/null | awk '{print $2}')
    if [ -n "$CURRENT" ] && [ "$CURRENT" != "$LAST_WALLPAPER" ] && [ -f "$CURRENT" ]; then
        matugen image "$CURRENT" 2>/dev/null
        LAST_WALLPAPER="$CURRENT"
    fi
    sleep 3
done
