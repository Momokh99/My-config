# My Config

Arch Linux dotfiles for Hyprland with Tokyo Night theme.

![Hyprland Desktop](hypr/wallpaper/20260508_14h01m35s_grim.png)

## Included

- **WM**: Hyprland (Lua-based config, keybinds, idle, lock, wallpaper)
- **Bar**: Waybar (workspaces, audio, network, battery, clock)
- **Launcher**: Wofi (+ wofi-power menu)
- **File Manager**: Yazi (terminal-based)
- **Notifications**: Mako
- **Terminals**: Kitty, Alacritty
- **Shell**: Zsh (Powerlevel10k, zoxide, fzf)
- **Editor**: Neovim (LazyVim-based)
- **Browser**: LibreWolf
- **System Info**: Fastfetch
- **Cursor**: Bibata Modern
- **Extra**: Bluetooth (bluetui), WiFi (wifitui), screenshots (grim + slurp + wl-clipboard), Stylus export

> **Note:** You can run any script with `bash script.sh` — no need to `chmod` unless you prefer `./script.sh`.

## Quick Start (Fresh Install)

**From Arch ISO → arch-chroot:**

```bash
pacman -S --noconfirm git
git clone https://github.com/Momokh99/My-config /root/My-config
cd /root/My-config
bash install_pack.sh
```

Running as root skips the AUR packages (`makepkg` refuses to run as root).
Install them after the first reboot:

```bash
yay -S --needed --noconfirm bibata-cursor-theme wifitui-bin
```

**After reboot (as normal user):**

```bash
sudo mv /root/My-config ~/My-config
sudo chown -R "$USER":"$USER" ~/My-config
cd ~/My-config
bash change_Shell.sh       # Set Zsh as default — log out then back in
bash install_conf.sh       # Deploy configs to ~/.config/
```

## Scripts

| Script | What it does | Details | Usage |
|---|---|---|---|
| `install_pack.sh` | Updates system, installs packages | Runs `pacman -Syu`, installs the pacman packages (nvim, kitty, opencode, hyprland, waybar, wofi, mako, awww, matugen, librewolf, yazi, ...), installs `yay` and the AUR packages (bibata-cursor-theme, wifitui-bin) when run as a normal user. As root/chroot the AUR step is skipped and the command to run later is printed | `bash install_pack.sh` (it calls `sudo` itself) |
| `change_Shell.sh` | Sets Zsh as default shell | Installs zsh via distro package manager if missing, adds it to `/etc/shells`, runs `chsh -s $(which zsh)` | `bash change_Shell.sh` — then log out & back in |
| `install_conf.sh` | Deploys configs with manual symlinks | Symlinks waybar, fastfetch, kitty, hypr, matugen, mako, alacritty, wofi, wofi-power, yazi into `~/.config/`; backs up existing directories/symlinks first; also symlinks the helper scripts (`wofi-power`, `wofi-screenshot`, `wofi-wallpaper`, `set-theme`, `gtk-themes-reload`) → `~/.local/bin/` | `bash install_conf.sh` |
| `backup.sh` | Backs up current configs | Copies waybar, fastfetch, kitty, hypr, matugen, mako, alacritty, wofi, yazi + `.bashrc` / `.zshrc` / `.tmux.conf` / `.config/kdeglobals` to `~/config/config$(date)/` | `bash backup.sh` |

## Keybinds (SUPER = Windows/Mod4)

| Key | Action |
|---|---|
| SUPER + Return | Terminal (kitty) |
| SUPER + E | File manager (kitty + yazi) |
| SUPER + space | App launcher (wofi) |
| SUPER + B | Browser (librewolf) |
| SUPER + N | Editor (kitty + nvim) |
| SUPER + O | Editor (kitty + opencode) |
| SUPER + C | Open My-config in nvim |
| SUPER + I | WiFi (kitty + wifitui) |
| SUPER + D | Bluetooth (kitty + bluetui) |
| SUPER + L | Power menu (wofi-power) |
| SUPER + W | Kill active window |
| SUPER + SHIFT + Q | Exit Hyprland |
| SUPER + V | Toggle floating |
| SUPER + F | Fullscreen |
| SUPER + P | Pseudo-tiling |
| SUPER + J | Toggle split |
| SUPER + S | Toggle special workspace (scratchpad) |
| SUPER + SHIFT + S | Move window to scratchpad |
| SUPER + Escape | Toggle Waybar on/off |
| CTRL + ALT + R | Restart Hyprland |
| CTRL + Escape | Toggle gaps / rounding / border 0 ↔ default |
| SUPER + left/right/up/down | Move focus |
| CTRL + Left/Right | Cycle workspaces |
| CTRL + SHIFT + Left/Right | Cycle existing workspaces |
| SUPER + &/é/"/'/(-/_/è/ç/à | Switch to workspace 1-10 (AZERTY) |
| SUPER + SHIFT + &/é/"/'/(-/_/è/ç/à | Move window to workspace 1-10 (AZERTY) |
| Print | Screenshot full → ~/Pictures/screenshoot |
| SUPER + Print | Screenshot region → ~/Pictures/screenshoot |
| SUPER + SHIFT + Print | Screenshot region → clipboard |
| XF86Audio* | Volume / media keys (wpctl / playerctl) |
| XF86MonBrightness* | Brightness keys (brightnessctl) |
| SUPER + mouse:LMB | Drag window |
| SUPER + mouse:RMB | Resize window |

## Theme

Tokyo Night — dark background (`#1a1b26`), blue accent (`#7aa2f7`), JetBrainsMono Nerd Font, Bibata Modern cursor.
