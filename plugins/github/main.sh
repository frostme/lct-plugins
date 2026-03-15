#!/usr/bin/env bash
set -Eeuo pipefail

GH_MATCHED_LOCAL_KEY=""

log() {
  gum style --foreground 252 "$*"
}

success() {
  gum style --foreground 42 "$*"
}

fail() {
  gum style --foreground 196 "Error: $*" >&2
  exit 1
}

command_exists() {
  command -v "$1" >/dev/null 2>&1
}

require_interactive() {
  if [[ ! -t 0 || ! -t 1 ]]; then
    fail "this script requires an interactive terminal"
  fi
}

ensure_gh_installed() {
  if command_exists gh; then
    success "GitHub CLI already installed"
    return
  fi

  log "GitHub CLI is not installed. Installing it now."

  if command_exists brew; then
    gum spin --title "Installing GitHub CLI with Homebrew" -- brew install gh
  elif command_exists apt-get; then
    gum spin --title "Refreshing apt package index" -- sudo apt-get update
    gum spin --title "Installing GitHub CLI with apt" -- sudo apt-get install -y gh
  elif command_exists dnf; then
    gum spin --title "Installing GitHub CLI with dnf" -- sudo dnf install -y gh
  elif command_exists yum; then
    gum spin --title "Installing GitHub CLI with yum" -- sudo yum install -y gh
  elif command_exists pacman; then
    gum spin --title "Installing GitHub CLI with pacman" -- sudo pacman -Sy --noconfirm github-cli
  else
    fail "could not install gh automatically. Install it manually and rerun this script"
  fi

  success "GitHub CLI installed"
}

ensure_gh_login() {
  if gh auth status >/dev/null 2>&1; then
    success "GitHub CLI already authenticated"
    return
  fi

  log "GitHub CLI is not authenticated. Complete the login flow."
  gh auth login
  gh auth status >/dev/null 2>&1 || fail "gh login did not complete successfully"
  success "GitHub CLI authenticated"
}

github_keys() {
  gh api user/keys --jq '.[] | [.title, .key] | @tsv'
}

local_public_keys() {
  local ssh_dir="$HOME/.ssh"
  [[ -d "$ssh_dir" ]] || return 0

  find "$ssh_dir" -maxdepth 1 -type f -name '*.pub' \
    ! -name 'known_hosts.pub' \
    ! -name 'authorized_keys.pub' \
    -print | sort
}

choose_from_menu() {
  local prompt="$1"
  shift
  gum choose --header "$prompt" "$@"
}

matching_local_key_for_github_key() {
  local github_key="$1"
  local pub_file

  while IFS= read -r pub_file; do
    [[ -n "$pub_file" ]] || continue
    if [[ "$(tr -d '\n' <"$pub_file" | awk '{NF--; print}')" == "$github_key" ]]; then
      printf '%s\n' "$pub_file"
      return 0
    fi
  done < <(local_public_keys)

  return 1
}

pick_existing_local_key() {
  local keys=()
  local pub_file

  while IFS= read -r pub_file; do
    [[ -n "$pub_file" ]] && keys+=("$pub_file")
  done < <(local_public_keys)

  ((${#keys[@]} > 0)) || fail "no local SSH public keys found in $HOME/.ssh"

  choose_from_menu "Choose a local SSH public key to add to GitHub:" "${keys[@]}"
}

generate_new_key() {
  local default_email
  default_email="$(git config --global user.email 2>/dev/null || true)"

  local email="$default_email"
  email="$(gum input --placeholder "you@example.com" --value "$default_email" --prompt "Email for new SSH key: ")"
  [[ -n "$email" ]] || fail "an email is required to generate a new SSH key"

  mkdir -p "$HOME/.ssh"

  local base_path="$HOME/.ssh/id_ed25519_github"
  local key_path="$base_path"
  local suffix=1
  while [[ -e "$key_path" || -e "${key_path}.pub" ]]; do
    key_path="${base_path}_${suffix}"
    ((suffix++))
  done

  gum spin --title "Generating a new SSH key at $key_path" -- \
    ssh-keygen -t ed25519 -C "$email" -f "$key_path"
  printf '%s\n' "${key_path}.pub"
}

add_key_to_github() {
  local pub_file="$1"
  local title="${2:-}"

  [[ -f "$pub_file" ]] || fail "public key file not found: $pub_file"

  if [[ -z "$title" ]]; then
    title="$(hostname)-$(basename "${pub_file%.pub}")"
  fi

  gum spin --title "Adding SSH key to GitHub" -- gh ssh-key add "$pub_file" --title "$title"
  success "Added SSH key to GitHub: $pub_file"
}

ensure_ssh_agent_running() {
  if ! ssh-add -l >/dev/null 2>&1; then
    # If the agent is unavailable, start one for this shell.
    eval "$(ssh-agent -s)" >/dev/null
  fi
}

agent_has_public_key() {
  local pub_file="$1"
  local pub_content
  pub_content="$(tr -d '\n' <"$pub_file")"
  ssh-add -L 2>/dev/null | grep -Fqx "$pub_content"
}

add_private_key_to_agent() {
  local pub_file="$1"
  local private_key="${pub_file%.pub}"

  [[ -f "$private_key" ]] || fail "private key not found for $pub_file"

  ensure_ssh_agent_running

  if agent_has_public_key "$pub_file"; then
    success "Matching SSH key already loaded in ssh-agent"
    return
  fi

  if [[ "$OSTYPE" == darwin* ]]; then
    gum spin --title "Adding SSH key to ssh-agent" -- ssh-add --apple-use-keychain "$private_key"
  else
    gum spin --title "Adding SSH key to ssh-agent" -- ssh-add "$private_key"
  fi

  success "Added SSH key to ssh-agent"
}

resolve_key_setup() {
  local github_key_rows=()
  local row

  while IFS= read -r row; do
    [[ -n "$row" ]] && github_key_rows+=("$row")
  done < <(github_keys)

  if ((${#github_key_rows[@]} == 0)); then
    log "No SSH keys found on GitHub."
    local mode
    mode="$(choose_from_menu "How would you like to continue?" "Use existing local SSH key" "Generate new SSH key")"
    if [[ "$mode" == "Use existing local SSH key" ]]; then
      GH_MATCHED_LOCAL_KEY="$(pick_existing_local_key)"
    else
      GH_MATCHED_LOCAL_KEY="$(generate_new_key)"
    fi
    add_key_to_github "$GH_MATCHED_LOCAL_KEY"
    return
  fi

  for row in "${github_key_rows[@]}"; do
    local github_title github_key local_match
    IFS=$'\t' read -r github_title github_key <<<"$row"
    if local_match="$(matching_local_key_for_github_key "$github_key")"; then
      GH_MATCHED_LOCAL_KEY="$local_match"
      success "Found local SSH key matching GitHub key: $github_title"
      return
    fi
  done

  log "GitHub has SSH keys configured, but none match a local public key."
  local mode
  mode="$(choose_from_menu "How would you like to continue?" "Use existing local SSH key" "Generate new SSH key")"
  if [[ "$mode" == "Use existing local SSH key" ]]; then
    GH_MATCHED_LOCAL_KEY="$(pick_existing_local_key)"
  else
    GH_MATCHED_LOCAL_KEY="$(generate_new_key)"
  fi
  add_key_to_github "$GH_MATCHED_LOCAL_KEY"
}

main() {
  require_interactive
  command_exists gum || fail "gum is required for this script"
  ensure_gh_installed
  ensure_gh_login
  resolve_key_setup
  add_private_key_to_agent "$GH_MATCHED_LOCAL_KEY"
  success "GitHub CLI and SSH setup complete"
}

main "$@"
