# github Plugin for LCT

This plugin sets up GitHub access on a machine by installing the GitHub CLI if needed and guiding the user through `gh auth login`.

It also helps reconcile local SSH keys with the keys registered on GitHub. If no matching key exists, the plugin can prompt the user to reuse an existing local key or generate a new one, add it to GitHub, and load the matching private key into `ssh-agent`.
