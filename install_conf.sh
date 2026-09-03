#!/bin/bash
set -e

DOTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CDIR="$HOME/.config"

cd "$DOTS_DIR"

configs=("waybar" "fastfetch" "kitty" "hypr" "wofi" "wofi-power" "wofi-screenshot" "wofi-wallpaper" "yazi" "nvim")

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
    #    Use dotglob/nullglob so .* and * are handled cleanly, and guard
    #    against self/recursive symlinks so re-running is idempotent.
    shopt -s dotglob nullglob
    for item in "$DOTS_DIR/$folder"/*; do
      basename_item=$(basename "$item")
      [[ "$basename_item" = "." || "$basename_item" = ".." ]] && continue
      target="$CDIR/$folder/$basename_item"
      # Skip if this item would link onto itself (prevents recursion)
      [[ "$(readlink -f "$item")" = "$(readlink -f "$target")" ]] && continue
      ln -sfr "$item" "$target"
    done
    shopt -u dotglob nullglob

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

# ─── Wofi-screenshot script symlink ───
if [ -e "$BINDIR/wofi-screenshot" ] && [ ! -L "$BINDIR/wofi-screenshot" ]; then
  echo "Backing up wofi-screenshot → wofi-screenshot.bak"
  mv "$BINDIR/wofi-screenshot" "$BINDIR/wofi-screenshot.bak"
fi
ln -sf "$DOTS_DIR/wofi-screenshot.sh" "$BINDIR/wofi-screenshot"
echo "Linked wofi-screenshot.sh → $BINDIR/wofi-screenshot"

# ─── Matugen wallpaper hook symlink ───
if [ -e "$BINDIR/matugen-wallpaper-hook" ] && [ ! -L "$BINDIR/matugen-wallpaper-hook" ]; then
  echo "Backing up matugen-wallpaper-hook → matugen-wallpaper-hook.bak"
  mv "$BINDIR/matugen-wallpaper-hook" "$BINDIR/matugen-wallpaper-hook.bak"
fi
ln -sf "$DOTS_DIR/matugen-wallpaper-hook.sh" "$BINDIR/matugen-wallpaper-hook"
echo "Linked matugen-wallpaper-hook.sh → $BINDIR/matugen-wallpaper-hook"

# ─── set-theme.sh symlink ───
if [ -e "$BINDIR/set-theme" ] && [ ! -L "$BINDIR/set-theme" ]; then
  echo "Backing up set-theme → set-theme.bak"
  mv "$BINDIR/set-theme" "$BINDIR/set-theme.bak"
fi
ln -sf "$DOTS_DIR/set-theme.sh" "$BINDIR/set-theme"
echo "Linked set-theme.sh → $BINDIR/set-theme"

# ─── Wofi-wallpaper script symlink ───
if [ -e "$BINDIR/wofi-wallpaper" ] && [ ! -L "$BINDIR/wofi-wallpaper" ]; then
  echo "Backing up wofi-wallpaper → wofi-wallpaper.bak"
  mv "$BINDIR/wofi-wallpaper" "$BINDIR/wofi-wallpaper.bak"
fi
ln -sf "$DOTS_DIR/wofi-wallpaper.sh" "$BINDIR/wofi-wallpaper"
echo "Linked wofi-wallpaper.sh → $BINDIR/wofi-wallpaper"

# ─── Tmux config (symlinked into $HOME, not ~/.config) ───
if [ -f "$HOME/.tmux.conf" ] && [ ! -L "$HOME/.tmux.conf" ]; then
  echo "Backing up .tmux.conf → .tmux.conf.bak"
  cp "$HOME/.tmux.conf" "$HOME/.tmux.conf.bak"
fi
ln -sfr "$DOTS_DIR/tmux/.tmux.conf" "$HOME/.tmux.conf"
echo "Linked .tmux.conf → $HOME/.tmux.conf"

echo "────────────────────────────────────────────────────────────"
echo " Finished linking"
