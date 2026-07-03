#!/usr/bin/env bash
set -Eeuo pipefail

oh_my_zsh_dir="${ZSH:-$HOME/.oh-my-zsh}"
zsh_custom_dir="${ZSH_CUSTOM:-$oh_my_zsh_dir/custom}"
powerlevel10k_dir="$zsh_custom_dir/themes/powerlevel10k"

if [[ -d "$powerlevel10k_dir" ]] && git -C "$powerlevel10k_dir" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "Skipping powerlevel10k: existing git checkout at $powerlevel10k_dir"
  exit 0
fi

if [[ -e "$powerlevel10k_dir" ]]; then
  echo "❌ powerlevel10k conflict: $powerlevel10k_dir already exists but is not a git checkout. Move or remove it and rerun the plugin." >&2
  exit 1
fi

mkdir -p "$(dirname "$powerlevel10k_dir")"
echo "Installing powerlevel10k into $powerlevel10k_dir"
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$powerlevel10k_dir"
echo "✅ powerlevel10k successfully installed"
