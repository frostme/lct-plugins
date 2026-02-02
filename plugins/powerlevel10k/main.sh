#!/usr/bin/env bash
set -Eeuo pipefail

# INSTALL POWERLEVEL10K
if [ ! -d "${ZSH_CUSTOM:-${ZSH:-~/.oh-my-zsh}/custom}/themes/powerlevel10k" ]; then
  echo "installing powerlevel10k"
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
  echo "✅ powerlevel10k succesfully installed"
fi
