#!/bin/bash
set -e

BACK_UP_DIR="$HOME/config/config$(date +%Y-%m-%d)"
mkdir -p "$BACK_UP_DIR"
#in .config
configs=("waybar" "fastfetch" "kitty" "hypr" "matugen" "mako" "wofi" "wofi-power" "wofi-screenshot" "wofi-wallpaper" "yazi" "nvim")
#in HOME
dotfiles=(".bashrc" ".zshrc")

echo " starting backup to $BACK_UP_DIR ..."

for folder in "${configs[@]}"; do
  if [ -d "$HOME/.config/$folder" ]; then
    cp -rL "$HOME/.config/$folder" "$BACK_UP_DIR"
    echo "  BACKUP DONE SUCCESSFULLY $folder"
  else
    echo "   NOT found"
  fi
done

for file in "${dotfiles[@]}"; do
  if [ -f "$HOME/$file" ]; then
    cp -rL "$HOME/$file" "$BACK_UP_DIR"
    echo "   BACKUP DONE SUCCESSFULLY $file"
  else
    echo "    NOT found"
  fi
done

echo "────────────────────────────────────────────────────────────"

echo " finished"
