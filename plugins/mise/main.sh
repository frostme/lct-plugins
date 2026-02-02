#!/usr/bin/env bash
set -Eeuo pipefail

# INSTALL MISE
if ! command -v mise &>/dev/null; then
  echo "installing mise"
  curl https://mise.run | sh
  echo 'eval "$(~/.local/bin/mise activate zsh)"' >>~/.zshrc
  mise install
  echo "✅ mise succesfully installed"
fi
