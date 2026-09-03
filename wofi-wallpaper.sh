#!/usr/bin/env bash
# Wallpaper picker with image previews (wofi dmenu mode)
WALL_DIR="$HOME/.config/hypr/wallpaper"

# Generate entries with image escape sequences: name\0icon\x1fpath
entries=""
for wp in "$WALL_DIR"/*.png "$WALL_DIR"/*.jpg "$WALL_DIR"/*.jpeg "$WALL_DIR"/*.webp; do
  [ -f "$wp" ] || continue
  name=$(basename "$wp")
  entries+="$(printf '%s\0icon\x1f%s\n' "$name" "$wp")"
done

chosen=$(printf '%s' "$entries" \
  | wofi --dmenu -I \
      --conf "$HOME/.config/wofi-wallpaper/config" \
      --style "$HOME/.config/wofi-wallpaper/style.css")

[ -z "$chosen" ] && exit 0

# Strip image escape sequences from selected entry, keep only the filename
selected="${chosen%%$'\0'*}"

exec set-theme "$WALL_DIR/$selected"
