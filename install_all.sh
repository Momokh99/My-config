#!/bin/bash

set_color=$(tput setaf 2) #GREEN
reset_color=$(tput sgr0)

pacman_packages=("firefox" "tree" "nvim" "clang" "pyright" "rust-analyzer" "gopls" "lua-language-server" "yaml-language-server" "bash-language-server" "vlc" "fastfetch" "kitty" "base-devel" "htop" "git")

AUR_PACKAGES=("")

#update system
echo "${set_color} ───────────────────── updating system reposotories ───────────────────── ${reset_color}"
sudo pacman -Syu --noconfirm

#install the pacman packages
echo "${set_color} ───────────────────── installing pacman packages ─────────────────────${reset_color}"
sudo pacman -S --noconfirm --needed "${pacman_packages[@]}"

#install YAY if not
if ! command -v yay &>/dev/null; then
  echo "${set_color} ───────────────────── yay not found installing  ───────────────────── ${reset_color}"
  #install git if not
  if ! command -v git &>/dev/null; then
    echo "${set_color} ───────────────────── git not found installing  ───────────────────── ${reset_color}"
    sudo pacman -S --noconfirm git
  fi
  git clone https://aur.archlinux.org/yay.git /tmp/yay
  cd /tmp/yay && makepkg -si --noconfirm
  cd ... || exit
fi

# --- 5. Install AUR Packages ---
echo "${set_color} ───────────────────── Installing AUR Packages ───────────────────── ${reset_color}"
yay -S --needed --noconfirm "${AUR_PACKAGES[@]}"

echo "${set_color} ───────────────────── Setup complete! Enjoy your Arch build ───────────────────── ${reset_color}"
