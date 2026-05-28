#!/bin/bash
set -e

if ! command -v zsh &>/dev/null; then
  echo "zsh not installed — installing..."
  if [ -f /etc/arch-release ]; then
    sudo pacman -S --noconfirm zsh
  elif [ -f /etc/debian_version ]; then
    sudo apt update && sudo apt install -y zsh
  elif [ -f /etc/fedora-release ]; then
    sudo dnf install -y zsh
  else
    echo "package manager not recognized"
    exit 1
  fi
else
  echo "zsh is installed"
fi

ZSH_PATH=$(which zsh)

# Ensure zsh is listed in /etc/shells (required by chsh)
if ! grep -qx "$ZSH_PATH" /etc/shells 2>/dev/null; then
  echo "$ZSH_PATH" | sudo tee -a /etc/shells >/dev/null
fi

CURRENT_SHELL=$(basename "$SHELL")

if [ "$CURRENT_SHELL" != "zsh" ]; then
  if ! command -v chsh &>/dev/null; then
    echo "chsh not found. Install it with your package manager."
    exit 1
  fi
  echo "changing default shell to zsh ..."
  sudo chsh -s "$ZSH_PATH" "$USER"
  echo "default shell changed — start a new terminal or run: exec zsh"
else
  echo "zsh is already your default shell"
fi
