#!/bin/bash
set -e

DOTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CDIR="$HOME/.config"

cd "$DOTS_DIR"

configs=("waybar" "fastfetch" "kitty" "hypr" "matugen" "mako" "alacritty" "gtk-3.0" "gtk-4.0" "qt5ct" "qt6ct" "wofi" "wofi-power" "wofi-screenshot" "wofi-wallpaper" "yazi" "nvim")

echo " Starting manual symlinking ..."

for folder in "${configs[@]}"; do
  [ -d "$folder" ] || continue

  src="$(readlink -f "$folder")"
  dest="$CDIR/$folder"

  # 1. Already deployed (previous run, NixOS/Home Manager): leave it alone.
  if [ -L "$dest" ] && [ "$(readlink -f "$dest")" = "$src" ]; then
    echo "$folder already linked"
    continue
  fi

  # 2. Move any existing path aside. `mv` keeps a stale symlink as a link
  #    instead of writing through it into whatever it used to point at.
  if [ -e "$dest" ] || [ -L "$dest" ]; then
    echo "Backing up $folder → ${folder}.bak"
    rm -rf "$CDIR/${folder}.bak"
    mv "$dest" "$CDIR/${folder}.bak"
  fi

  # 3. Ensure target directory exists
  mkdir -p "$dest"

  # 4. Symlink each item inside the source folder into the target.
  #    dotglob/nullglob handle dotfiles, and the readlink guard keeps
  #    re-runs idempotent (no link pointing at itself).
  shopt -s dotglob nullglob
  for item in "$DOTS_DIR/$folder"/*; do
    basename_item=$(basename "$item")
    target="$dest/$basename_item"
    # Skip if this item would link onto itself (prevents recursion)
    [ "$(readlink -f "$item")" = "$(readlink -f "$target")" ] && continue
    # -T replaces the target itself. -f cannot overwrite a real directory,
    # so move one aside first (e.g. a subdirectory that was never linked).
    if [ -d "$target" ] && [ ! -L "$target" ]; then
      echo "Backing up $folder/$basename_item → $basename_item.bak"
      rm -rf "${target}.bak"
      mv "$target" "${target}.bak"
    fi
    ln -sfrT "$item" "$target"
  done
  shopt -u dotglob nullglob

  echo "Linked contents of $folder"
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

# ─── gtk-themes-reload (matugen's GTK post-hook) symlink ───
if [ -e "$BINDIR/gtk-themes-reload" ] && [ ! -L "$BINDIR/gtk-themes-reload" ]; then
  echo "Backing up gtk-themes-reload → gtk-themes-reload.bak"
  mv "$BINDIR/gtk-themes-reload" "$BINDIR/gtk-themes-reload.bak"
fi
ln -sf "$DOTS_DIR/matugen/post-hook-scripts/gtk-themes-reload.sh" "$BINDIR/gtk-themes-reload"
echo "Linked gtk-themes-reload.sh → $BINDIR/gtk-themes-reload"

# ─── Tmux config (symlinked into $HOME, not ~/.config) ───
if [ -f "$HOME/.tmux.conf" ] && [ ! -L "$HOME/.tmux.conf" ]; then
  echo "Backing up .tmux.conf → .tmux.conf.bak"
  cp "$HOME/.tmux.conf" "$HOME/.tmux.conf.bak"
fi
ln -sfr "$DOTS_DIR/tmux/.tmux.conf" "$HOME/.tmux.conf"
echo "Linked .tmux.conf → $HOME/.tmux.conf"

# ─── kdeglobals (KDE color scheme selection, symlinked into ~/.config) ───
if [ -f "$HOME/.config/kdeglobals" ] && [ ! -L "$HOME/.config/kdeglobals" ]; then
  echo "Backing up kdeglobals → kdeglobals.bak"
  cp "$HOME/.config/kdeglobals" "$HOME/.config/kdeglobals.bak"
fi
ln -sfr "$DOTS_DIR/kdeglobals" "$HOME/.config/kdeglobals"
echo "Linked kdeglobals → $HOME/.config/kdeglobals"

# ─── wallpaper-pack symlink (compressed wallpapers in git) ───
if [ -e "$BINDIR/wallpaper-pack" ] && [ ! -L "$BINDIR/wallpaper-pack" ]; then
  echo "Backing up wallpaper-pack → wallpaper-pack.bak"
  mv "$BINDIR/wallpaper-pack" "$BINDIR/wallpaper-pack.bak"
fi
ln -sf "$DOTS_DIR/wallpaper-pack.sh" "$BINDIR/wallpaper-pack"
echo "Linked wallpaper-pack.sh → $BINDIR/wallpaper-pack"

# Extract the wallpaper pack (no-op when already current).
"$BINDIR/wallpaper-pack" sync || echo "warning: wallpaper extraction failed"

echo "────────────────────────────────────────────────────────────"
echo " Finished linking"
