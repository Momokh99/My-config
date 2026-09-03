#!/usr/bin/env bash
# Wallpaper picker with image previews (wofi dmenu mode)
WALL_DIR="$HOME/.config/hypr/wallpaper"

# Pipe entries with image escapes directly to wofi (avoids $(...) newline stripping).
# wofi image escape: name\0img\x1f/path/to/image
chosen=$( \
  while IFS= read -r wp; do
    name=$(basename "$wp")
    printf '%s\0img\x1f%s\n' "$name" "$wp"
  done < <(find -L "$WALL_DIR" -maxdepth 1 -type f \
    \( -name '*.png' -o -name '*.jpg' -o -name '*.jpeg' -o -name '*.webp' \) | sort) \
  | wofi --dmenu -I \
      --conf "$HOME/.config/wofi-wallpaper/config" \
      --style "$HOME/.config/wofi-wallpaper/style.css")

[ -z "$chosen" ] && exit 0

# Strip image escape sequences, keep only the filename
selected="${chosen%%$'\0'*}"

exec "$HOME/.local/bin/set-theme" "$WALL_DIR/$selected"
