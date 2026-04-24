#!/bin/bash

if ! command -v zsh &>/dev/null; then
  echo "zsh not installed       installing..."
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

CURENT_SHELL=$(basename "$SHELL")

if [ "$CURENT_SHELL" != "zsh" ]; then
  echo "changing default shell to zsh ..."
  chsh -s "$(which zsh)"
  echo "shell changed log in and log out"
else
  echo "zsh is already your default"
fi
