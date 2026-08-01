#!/bin/bash
set -e

DOTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CDIR="$HOME/.config"

cd "$DOTS_DIR"

configs=("waybar" "fastfetch" "kitty" "hypr" "wofi" "wofi-power" "yazi" "quickshell" "nvim")

echo " Starting manual symlinking ..."

for folder in "${configs[@]}"; do
  if [ -d "$folder" ]; then
    # 1. Back up the physical directory if it exists and isn't a symlink
    if [ -e "$CDIR/$folder" ] && [ ! -L "$CDIR/$folder" ]; then
      echo "Backing up $folder → ${folder}.bak"
      rm -rf "$CDIR/${folder}.bak"
      mv "$CDIR/$folder" "$CDIR/${folder}.bak"
    fi

    # 2. Ensure target directory exists
    mkdir -p "$CDIR/$folder"

    # 3. Symlink each item inside the source folder into the target
    for item in "$DOTS_DIR/$folder"/* "$DOTS_DIR/$folder"/.*; do
      basename_item=$(basename "$item")
      [[ "$basename_item" = "." || "$basename_item" = ".." ]] && continue
      ln -sfr "$item" "$CDIR/$folder/$basename_item"
    done

    echo "Linked contents of $folder"
  fi
done

# ─── Wofi-power script symlink ───
BINDIR="$HOME/.local/bin"
mkdir -p "$BINDIR"

if [ -e "$BINDIR/wofi-power" ] && [ ! -L "$BINDIR/wofi-power" ]; then
  echo "Backing up wofi-power → wofi-power.bak"
  mv "$BINDIR/wofi-power" "$BINDIR/wofi-power.bak"
fi
ln -sf "$DOTS_DIR/wofi-power.sh" "$BINDIR/wofi-power"
echo "Linked wofi-power.sh → $BINDIR/wofi-power"

# ─── Tmux config (symlinked into $HOME, not ~/.config) ───
if [ -f "$HOME/.tmux.conf" ] && [ ! -L "$HOME/.tmux.conf" ]; then
  echo "Backing up .tmux.conf → .tmux.conf.bak"
  cp "$HOME/.tmux.conf" "$HOME/.tmux.conf.bak"
fi
ln -sfr "$DOTS_DIR/tmux/.tmux.conf" "$HOME/.tmux.conf"
echo "Linked .tmux.conf → $HOME/.tmux.conf"

echo "────────────────────────────────────────────────────────────"
echo " Finished linking"
