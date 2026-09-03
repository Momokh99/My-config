#!/usr/bin/env bash
# Wallpaper picker (wofi dmenu mode)
WALL_DIR="$HOME/.config/hypr/wallpaper"

chosen=$(
  find "$WALL_DIR" -maxdepth 1 -type f \
    \( -name '*.png' -o -name '*.jpg' -o -name '*.jpeg' -o -name '*.webp' \) -printf '%f\n' \
  | sort \
  | wofi --dmenu \
      --conf "$HOME/.config/wofi-wallpaper/config" \
      --style "$HOME/.config/wofi-wallpaper/style.css"
)

[ -z "$chosen" ] && exit 0

exec "$HOME/.local/bin/set-theme" "$WALL_DIR/$chosen"
