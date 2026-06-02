#!/bin/bash
set -e

set_color=$(tput setaf 2) #GREEN
reset_color=$(tput sgr0)

pacman_packages=("firefox" "tree" "nvim" "vlc" "fastfetch" "kitty" "base-devel" "htop" "fd" "nodejs" "npm" "python-pip" "unzip" "wget" "curl" "zsh" "git" "lazygit" "opencode" "stow" "hyprland" "hyprshutdown" "waybar" "wofi" "mako" "wl-clipboard" "hyprlock" "hypridle" "hyprpaper" "grim" "slurp" "brightnessctl" "playerctl" "dolphin" "wireplumber" "ttf-jetbrains-mono-nerd")

AUR_PACKAGES=("zen-browser-bin")

#update system
echo "${set_color} ───────────────────── updating system repositories ───────────────────── ${reset_color}"
sudo pacman -Syu --noconfirm

#install the pacman packages
echo "${set_color} ───────────────────── installing pacman packages ─────────────────────${reset_color}"
sudo pacman -S --noconfirm --needed "${pacman_packages[@]}"

#install YAY if not
if ! command -v yay &>/dev/null; then
  echo "${set_color} ───────────────────── yay not found installing  ───────────────────── ${reset_color}"
  git clone https://aur.archlinux.org/yay.git /tmp/yay
  cd /tmp/yay && makepkg -si --noconfirm
  cd /tmp || exit
fi

# --- 5. Install AUR Packages ---
echo "${set_color} ───────────────────── Installing AUR Packages ───────────────────── ${reset_color}"
yay -S --needed --noconfirm "${AUR_PACKAGES[@]}"

echo "${set_color} ───────────────────── Setup complete! Enjoy your Arch build ───────────────────── ${reset_color}"
