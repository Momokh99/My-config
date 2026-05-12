# My Config

Arch Linux dotfiles for Hyprland with Tokyo Night theme.

## Included

- **WM**: Hyprland (keybinds, gestures, idle, lock, wallpaper)
- **Bar**: Waybar (workspaces, audio, network, battery, clock)
- **Launcher**: Wofi
- **Terminals**: Kitty, Alacritty
- **Shell**: Zsh (Powerlevel10k, zoxide, fzf)
- **System Info**: Fastfetch

## Quick Start

```bash
./install_pack.sh    # Install packages (pacman + AUR)
./change_Shell.sh    # Set Zsh as default shell (log out & back in)
./install_conf.sh    # Deploy configs to ~/.config/
```

## Keybinds (SUPER = Windows/Mod4)

| Key | Action |
|---|---|
| SUPER + Q | Terminal (kitty) |
| SUPER + E | File manager (dolphin) |
| SUPER + D | App launcher (wofi) |
| SUPER + W | Browser (zen/firefox) |
| SUPER + Esc | Lock screen |
| SUPER + 1-9 | Switch workspace |
| SUPER + SHIFT + 1-9 | Move window to workspace |

## Theme

Tokyo Night — dark background (`#1a1b26`), blue accent (`#7aa2f7`), JetBrainsMono Nerd Font.
