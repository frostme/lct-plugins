# powerlevel10k Plugin for LCT

This plugin installs the Powerlevel10k theme into an Oh My Zsh custom themes directory.

It is intended to pair with the `ohmyzsh` plugin and gives the shell a fast, highly configurable prompt, while allowing the user's `~/.p10k.zsh` configuration to be tracked separately.

## Idempotency and conflicts

- If the theme directory is missing, the plugin clones Powerlevel10k into the Oh My Zsh custom themes directory.
- If the target directory already exists as a Git checkout, the plugin skips it and leaves the checkout untouched.
- If the target path already exists but is not a Git checkout, the plugin fails with a recovery message instead of overwriting user-owned files.

## Manual verification

Run the plugin twice and confirm the second run reports a skip message for `~/.oh-my-zsh/custom/themes/powerlevel10k`.

Then create a non-Git directory at that path and confirm the plugin exits with a conflict message rather than deleting or overwriting it.
