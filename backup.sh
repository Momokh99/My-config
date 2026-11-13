#!/bin/bash
set -e

BACK_UP_DIR="$HOME/config/config$(date +%Y-%m-%d)"
mkdir -p "$BACK_UP_DIR"
#in .config
configs=("waybar" "fastfetch" "kitty" "hypr" "matugen" "mako" "alacritty" "gtk-3.0" "gtk-4.0" "qt5ct" "qt6ct" "wofi" "wofi-power" "wofi-screenshot" "wofi-wallpaper" "yazi" "nvim")
#in HOME
dotfiles=(".bashrc" ".zshrc" ".tmux.conf" ".config/kdeglobals")

echo " starting backup to $BACK_UP_DIR ..."

for folder in "${configs[@]}"; do
  if [ -d "$HOME/.config/$folder" ]; then
    # Replace the previous copy: re-running on the same day must not nest
    # (configDATE/hypr/hypr), and deleted files must not linger.
    rm -rf "$BACK_UP_DIR/$folder"
    mkdir -p "$BACK_UP_DIR/$folder"
    cp -rL "$HOME/.config/$folder/." "$BACK_UP_DIR/$folder/"
    echo "  BACKUP DONE SUCCESSFULLY $folder"
  else
    echo "   NOT found"
  fi
done

for file in "${dotfiles[@]}"; do
  if [ -f "$HOME/$file" ]; then
    # Keep the relative path (.config/kdeglobals), so restoring is a plain copy.
    mkdir -p "$BACK_UP_DIR/$(dirname "$file")"
    cp -rL "$HOME/$file" "$BACK_UP_DIR/$file"
    echo "   BACKUP DONE SUCCESSFULLY $file"
  else
    echo "    NOT found"
  fi
done

echo "────────────────────────────────────────────────────────────"

echo " finished"
