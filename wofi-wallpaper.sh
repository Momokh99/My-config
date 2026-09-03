#!/usr/bin/env bash
# Wallpaper picker with image previews (wofi dmenu mode)
WALL_DIR="$HOME/.config/hypr/wallpaper"

# Build entries with image escape sequences: name\0icon\x1fpath
entries=""
while IFS= read -r wp; do
  name=$(basename "$wp")
  entries+="$(printf '%s\0icon\x1f%s\n' "$name" "$wp")"
done < <(find -L "$WALL_DIR" -maxdepth 1 -type f \
  \( -name '*.png' -o -name '*.jpg' -o -name '*.jpeg' -o -name '*.webp' \) | sort)

chosen=$(printf '%s' "$entries" \
  | wofi --dmenu -I \
      --conf "$HOME/.config/wofi-wallpaper/config" \
      --style "$HOME/.config/wofi-wallpaper/style.css")

[ -z "$chosen" ] && exit 0

# Strip image escape sequences, keep only the filename
selected="${chosen%%$'\0'*}"

exec "$HOME/.local/bin/set-theme" "$WALL_DIR/$selected"
