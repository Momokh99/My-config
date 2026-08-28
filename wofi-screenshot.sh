#!/usr/bin/env bash

SCREENSHOT_DIR="${SCREENSHOT_DIR:-$HOME/Pictures/screenshoot}"
mkdir -p "$SCREENSHOT_DIR"

CONF="$HOME/.config/wofi-screenshot/config"
STYLE="$HOME/.config/wofi-screenshot/style.css"

FULL="Full Screen"
REGION="Region"
CLIP_REGION="Clipboard Region"
CLIP_FULL="Clipboard Full Screen"

chosen=$(printf '%s\n' "$FULL" "$REGION" "$CLIP_REGION" "$CLIP_FULL" | wofi --dmenu --conf "$CONF" --style "$STYLE")
chosen=$(echo "$chosen" | xargs)

while pgrep -x wofi >/dev/null 2>&1; do sleep 0.05; done
sleep 0.3

case "$chosen" in
  "$FULL")
    file="$SCREENSHOT_DIR/$(date +'%Y-%m-%d_%H-%M-%S').png"
    grim "$file" && notify-send -a screenshot "Screenshot" "Full screen saved to $file"
    ;;
  "$REGION")
    file="$SCREENSHOT_DIR/$(date +'%Y-%m-%d_%H-%M-%S').png"
    grim -g "$(slurp)" "$file" && notify-send -a screenshot "Screenshot" "Region saved to $file"
    ;;
  "$CLIP_REGION")
    grim -g "$(slurp)" - | wl-copy && notify-send -a screenshot "Screenshot" "Region copied to clipboard"
    ;;
  "$CLIP_FULL")
    grim - | wl-copy && notify-send -a screenshot "Screenshot" "Full screen copied to clipboard"
    ;;
  *)
    exit 0
    ;;
esac