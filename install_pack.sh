#!/bin/bash
set -e

# tput fails on a non-TTY (CI, chroot without TERM) and `set -e` would abort.
if [ -t 1 ] && [ -n "${TERM:-}" ] && command -v tput >/dev/null 2>&1; then
  set_color=$(tput setaf 2) #GREEN
  reset_color=$(tput sgr0)
else
  set_color=""
  reset_color=""
fi

pacman_packages=(
  "tree"
  "nvim"
  "vlc"
  "fastfetch"
  "kitty"
  "base-devel"
  "htop"
  "fd"
  "nodejs"
  "npm"
  "python-pip"
  "unzip"
  "wget"
  "curl"
  "zsh"
  "git"
  "lazygit"
  "opencode"
  "tmux"
  "hyprland"
  "hyprshutdown"
  "waybar"
  "wofi"
  "mako"
  "wl-clipboard"
  "hyprlock"
  "hypridle"
  "awww"
  "grim"
  "slurp"
  "libnotify"
  "brightnessctl"
  "playerctl"
  "dolphin"
  "wireplumber"
  "ttf-jetbrains-mono-nerd"
  "yazi"
  "tree-sitter"
  "matugen"
  "imagemagick"
  "adw-gtk-theme"
  "kconfig"
  "librewolf"
  "bluetui"
)

AUR_PACKAGES=("bibata-cursor-theme" "wifitui-bin")

#update system
echo "${set_color} ───────────────────── updating system repositories ───────────────────── ${reset_color}"
sudo pacman -Syu --noconfirm

#install the pacman packages
echo "${set_color} ───────────────────── installing pacman packages ─────────────────────${reset_color}"
sudo pacman -S --noconfirm --needed "${pacman_packages[@]}"

#install YAY and the AUR packages (makepkg refuses to run as root)
if [ "$(id -u)" -eq 0 ]; then
  echo "${set_color} ───────────────────── skipping AUR packages (running as root) ───────────────────── ${reset_color}"
  echo "After the first reboot, install them as your normal user with:"
  echo "  yay -S --needed --noconfirm ${AUR_PACKAGES[*]}"
else
  if ! command -v yay &>/dev/null; then
    echo "${set_color} ───────────────────── yay not found installing  ───────────────────── ${reset_color}"
    build_dir="$(mktemp -d)"
    trap 'rm -rf "$build_dir"' EXIT
    git clone https://aur.archlinux.org/yay.git "$build_dir/yay"
    (cd "$build_dir/yay" && makepkg -si --noconfirm)
  fi

  echo "${set_color} ───────────────────── Installing AUR Packages ───────────────────── ${reset_color}"
  yay -S --needed --noconfirm "${AUR_PACKAGES[@]}"
fi

echo "${set_color} ───────────────────── Setup complete! Enjoy your Arch build ───────────────────── ${reset_color}"
