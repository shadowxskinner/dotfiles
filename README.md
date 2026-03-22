# Dotfiles

My personal cross-platform setup for macOS and Arch Linux / Hyprland.

This repo is used to back up and quickly restore my main terminal, editor, and desktop environment after a reinstall.

## What is in this repo

### Shared
- Kitty config
- Neovim / LazyVim config
- `.zshrc`
- setup scripts

### macOS
- Homebrew packages via `Brewfile`
- `macos-setup.sh`

### Linux / Hyprland
- Hyprland config
- Waybar config
- `keyd` config for Mac-like `Super` shortcuts

## Repo layout

```text
dotfiles/
├── .config/
│   ├── hypr/
│   │   └── hyprland.conf
│   ├── kitty/
│   │   ├── current-theme.conf
│   │   ├── kitty.app.icns
│   │   └── kitty.conf
│   ├── nvim/
│   │   ├── init.lua
│   │   ├── lazy-lock.json
│   │   ├── lazyvim.json
│   │   ├── lua/
│   │   └── stylua.toml
│   └── waybar/
│       ├── config
│       └── style.css
├── keyd/
│   └── default.conf
├── .gitignore
├── .zshrc
├── Brewfile
├── install.sh
├── macos-setup.sh
└── README.md
