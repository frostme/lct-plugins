# ohmyzsh Plugin for LCT

This plugin installs Oh My Zsh and augments it with a small set of quality-of-life plugins.

In addition to the base framework, it installs `zsh-completions`, `zsh-syntax-highlighting`, and `zsh-autosuggestions` to improve shell completion, feedback, and interactive command entry.

## Idempotency and conflicts

- If Oh My Zsh or one of the companion plugin directories is missing, the plugin clones it.
- If the target directory already exists as a Git checkout, the plugin skips it and leaves the existing checkout untouched.
- If the target path already exists but is not a Git checkout, the plugin fails with a recovery message instead of overwriting user-owned files.

This plugin no longer runs the upstream Oh My Zsh installer script, so it does not rewrite `~/.zshrc` during bootstrap.

## Manual verification

Run the plugin twice and confirm the second run reports skip messages for:

- `~/.oh-my-zsh`
- `~/.oh-my-zsh/custom/plugins/zsh-completions`
- `~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting`
- `~/.oh-my-zsh/custom/plugins/zsh-autosuggestions`

Then create a non-Git directory at one of those paths and confirm the plugin exits with a conflict message rather than deleting or overwriting it.
