#!/usr/bin/env bash
set -Eeuo pipefail

oh_my_zsh_dir="${ZSH:-$HOME/.oh-my-zsh}"
zsh_custom_dir="${ZSH_CUSTOM:-$oh_my_zsh_dir/custom}"

is_git_checkout() {
  local path="$1"
  git -C "$path" rev-parse --is-inside-work-tree >/dev/null 2>&1
}

ensure_git_checkout() {
  local label="$1"
  local repo_url="$2"
  local dest="$3"
  local clone_args=()

  if [[ $# -gt 3 ]]; then
    clone_args=("${@:4}")
  fi

  if [[ -d "$dest" ]] && is_git_checkout "$dest"; then
    echo "Skipping $label: existing git checkout at $dest"
    return 0
  fi

  if [[ -e "$dest" ]]; then
    echo "❌ $label conflict: $dest already exists but is not a git checkout. Move or remove it and rerun the plugin." >&2
    return 1
  fi

  mkdir -p "$(dirname "$dest")"
  echo "Installing $label into $dest"
  if [[ ${#clone_args[@]} -gt 0 ]]; then
    git clone "${clone_args[@]}" "$repo_url" "$dest"
  else
    git clone "$repo_url" "$dest"
  fi
  echo "✅ $label successfully installed"
}

ensure_git_checkout "oh-my-zsh" "https://github.com/ohmyzsh/ohmyzsh.git" "$oh_my_zsh_dir" --depth=1
ensure_git_checkout "zsh-completions" "https://github.com/zsh-users/zsh-completions.git" "$zsh_custom_dir/plugins/zsh-completions"
ensure_git_checkout "zsh-syntax-highlighting" "https://github.com/zsh-users/zsh-syntax-highlighting.git" "$zsh_custom_dir/plugins/zsh-syntax-highlighting"
ensure_git_checkout "zsh-autosuggestions" "https://github.com/zsh-users/zsh-autosuggestions" "$zsh_custom_dir/plugins/zsh-autosuggestions"
