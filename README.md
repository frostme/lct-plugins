# lct-plugins hub

A central hub for LCT plugin definitions. This directory contains a collection of plugins that can be enabled in your lct config.yaml. Each plugin includes a short description and a README describing its purpose and installation steps.

## Plugins

- [Alacritty](plugins/alacritty/README.md): Terminal emulator plugin for macOS. Installs and configures Alacritty; see the plugin README for details.
- [jrnl](plugins/jrnl/README.md): Lightweight journaling CLI tool. Installs via pip and provides a simple journaling interface; see the plugin README for details.
- [LazyVim](plugins/lazyvim/README.md): Bootstrap Neovim configuration with LazyVim starter; see the plugin README for details.
- [mise](plugins/mise/README.md): Command-line tooling (mise); see the plugin README for details.
- [ohmyzsh](plugins/ohmyzsh/README.md): Oh My Zsh setup with recommended plugins and themes; see the plugin README for details.
- [powerlevel10k](plugins/powerlevel10k/README.md): Powelevel10k theme for Zsh; see the plugin README for details.

## How to enable plugins

In your lct config.yaml, reference the plugins by their directory paths under plugins. For example:

```
plugins:
  - frostme/lct-plugins.alacritty
  - frostme/lct-plugins.jrnl
  - frostme/lct-plugins.lazyvim
  - frostme/lct-plugins.mise
  - frostme/lct-plugins.ohmyzsh
  - frostme/lct-plugins.powerlevel10k
```

Each plugin contains its own config.yaml (if needed) and a README with installation and usage details.
