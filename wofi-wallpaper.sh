#!/usr/bin/env bash
# Wallpaper picker with image previews (wofi dmenu mode)
WALL_DIR="$HOME/.config/hypr/wallpaper"

# Pipe entries to wofi. wofi splits on ':' and treats 'img' as an image mode.
# No leading text token so only the thumbnail renders (no filename label).
chosen=$( \
  while IFS= read -r wp; do
    printf ':img:%s\n' "$wp"
  done < <(find -L "$WALL_DIR" -maxdepth 1 -type f \
    \( -name '*.png' -o -name '*.jpg' -o -name '*.jpeg' -o -name '*.webp' \) | sort) \
  | wofi --dmenu -I \
      --conf "$HOME/.config/wofi-wallpaper/config" \
      --style "$HOME/.config/wofi-wallpaper/style.css")

[ -z "$chosen" ] && exit 0

# Extract the image path after ':img:'
selected="${chosen#*:img:}"

exec "$HOME/.local/bin/set-theme" "$selected"
