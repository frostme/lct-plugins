#!/usr/bin/env bash
set -Eeuo pipefail

if ! command -v jrnl &>/dev/null; then
  echo "installing jrnl"
  pip install jrnl
  echo "✅ jrnl succesfully installed"
else
  echo "✅ jrnl already installed"
fi
