#!/usr/bin/env bash
# Wallpaper picker with image previews (wofi dmenu mode)
WALL_DIR="$HOME/.config/hypr/wallpaper"

# Pipe entries to wofi. wofi's image escape is colon-delimited:
# name:img:/path/to/image  (wofi splits on ':' and treats 'img' as an image mode)
chosen=$( \
  while IFS= read -r wp; do
    name=$(basename "$wp")
    printf '%s:img:%s\n' "$name" "$wp"
  done < <(find -L "$WALL_DIR" -maxdepth 1 -type f \
    \( -name '*.png' -o -name '*.jpg' -o -name '*.jpeg' -o -name '*.webp' \) | sort) \
  | wofi --dmenu -I \
      --conf "$HOME/.config/wofi-wallpaper/config" \
      --style "$HOME/.config/wofi-wallpaper/style.css")

[ -z "$chosen" ] && exit 0

# Extract the wallpaper filename (everything before the first ':')
selected="${chosen%%:*}"

exec "$HOME/.local/bin/set-theme" "$WALL_DIR/$selected"
