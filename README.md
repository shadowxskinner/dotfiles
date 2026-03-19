# Dotfiles

My personal cross-platform setup for **macOS** and **Arch Linux / Hyprland**.

This repo is used to back up and restore my main terminal/editor environment quickly after a reinstall.

## What is in this repo

### Shared
- Kitty config
- Neovim / LazyVim config
- `.zshrc`
- GitHub workflow
- setup scripts

### macOS
- Homebrew packages with `Brewfile`
- `macos-setup.sh`

### Linux / Hyprland
- Hyprland config
- Waybar config
- Linux-specific setup script later

---

## Repo layout

```text
dotfiles/
├── .config/
│   ├── kitty/
│   ├── nvim/
│   ├── hypr/
│   └── waybar/
├── .zshrc
├── Brewfile
├── install.sh
├── macos-setup.sh
└── README.md
