#!/bin/bash
set -e

DOTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CDIR="$HOME/.config"

cd "$DOTS_DIR"

configs=("waybar" "fastfetch" "kitty" "hypr" "wofi")

echo " Starting GNU Stow symlinking ..."

for folder in "${configs[@]}"; do
  if [ -d "$folder" ]; then

    # 1. Back up the physical directory if it exists and isn't a symlink
    if [ -e "$CDIR/$folder" ] && [ ! -L "$CDIR/$folder" ]; then
      echo "Backing up $folder → ${folder}.bak"
      rm -rf "$CDIR/${folder}.bak"
      mv "$CDIR/$folder" "$CDIR/${folder}.bak"
    fi

    # 2. Now we safely make the target folder a physical directory
    mkdir -p "$CDIR/$folder"

    # 3. Use -d to tell Stow the package is inside the folder,
    # and use "." to stow everything inside it into the target folder
    stow -R -d "$folder" -t "$CDIR/$folder" .

    echo "Stowed contents of $folder"
  fi
done

echo "────────────────────────────────────────────────────────────"
echo " Finished stowing"
