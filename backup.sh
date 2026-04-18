#!/bin/bash

BACK_UP_DIR="$HOME/config/config$(date +%Y-%m-%d)"
mkdir -p "$BACK_UP_DIR"
#in .config
configs=("waybar" "Kvantum" "fastfetch" "kitty" "hypr" "rofi")
#in HOME
dotfiles=(".bashrc" ".zshrc")

echo " starting backup to $BACK_UP_DIR ..."

for folder in "${configs[@]}"; do
  if [ -d "$HOME/.config/$folder" ]; then
    cp -r "$HOME/.config/$folder" "$BACK_UP_DIR"
    echo "  BACKUP DONE SUCCESUVELY $folder"
  else
    echo "   NOT found"
  fi
done

for file in "${dotfiles[@]}"; do
  if [ -d "$HOME/$file" ]; then
    cp -r "$HOME/$file" "$BACK_UP_DIR"
    echo "   BACKUP DONE SUCCESUVELY $folder"
  else
    echo "    NOT found"
  fi
done

echo "────────────────────────────────────────────────────────────"

echo " finished"
