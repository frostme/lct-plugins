#!/usr/bin/env bash
set -Eeuo pipefail

# INSTALL lazyvim
if [ ! -f "$HOME/.config/nvim/lazyvim.json" ]; then
  echo "Backing up existing nvim config if it exists"
  if [ -d $HOME/.config/nvim ]; then
    mv $HOME/.config/nvim $HOME/.config/nvim.bak
  fi

  if [ -d $HOME/.local/share/nvim ]; then
    mv $HOME/.local/share/nvim $HOME/.local/share/nvim.bak
  fi

  if [ -d "$HOME/.local/state/nvim" ]; then
    mv "$HOME/.local/state/nvim" "$HOME/.local/state/nvim.bak"
  fi

  if [ -d "$HOME/.cache/nvim" ]; then
    mv "$HOME/.cache/nvim" "$HOME/.cache/nvim.bak"
  fi

  echo "Installing LazyVim"
  git clone https://github.com/LazyVim/starter ~/.config/nvim
  rmz -f ~/.config/nvim/.git
fi
