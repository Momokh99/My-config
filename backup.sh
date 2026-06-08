#!/bin/bash
set -e

BACK_UP_DIR="$HOME/config/config$(date +%Y-%m-%d)"
mkdir -p "$BACK_UP_DIR"
#in .config
configs=("waybar" "fastfetch" "kitty" "hypr" "wofi" "yazi")
#in HOME
dotfiles=(".bashrc" ".zshrc")

echo " starting backup to $BACK_UP_DIR ..."

for folder in "${configs[@]}"; do
  if [ -d "$HOME/.config/$folder" ]; then
    cp -r "$HOME/.config/$folder" "$BACK_UP_DIR"
    echo "  BACKUP DONE SUCCESSFULLY $folder"
  else
    echo "   NOT found"
  fi
done

for file in "${dotfiles[@]}"; do
  if [ -f "$HOME/$file" ]; then
    cp -r "$HOME/$file" "$BACK_UP_DIR"
    echo "   BACKUP DONE SUCCESSFULLY $file"
  else
    echo "    NOT found"
  fi
done

echo "────────────────────────────────────────────────────────────"

echo " finished"
