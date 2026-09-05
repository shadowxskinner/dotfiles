#!/usr/bin/env bash
set -euo pipefail

repo_dir="$(cd "$(dirname "$0")" && pwd)"
backup="$HOME/.config-backups/dotfiles-$(date +%Y%m%d-%H%M%S)"

deploy() {
  local name="$1" src="$repo_dir/.config/$1" dst="$HOME/.config/$1"
  [[ -d "$src" ]] || { echo "Missing source: $src" >&2; return 1; }

  if [[ -e "$dst" || -L "$dst" ]]; then
    mkdir -p "$backup"
    mv "$dst" "$backup/$name"
    echo "Backed up $dst to $backup/$name"
  fi

  ln -s "$src" "$dst"
  echo "Linked $dst -> $src"
}

mkdir -p "$HOME/.config"
deploy hypr
deploy waybar

echo "Configuration installed. Log out and select Hyprland in SDDM."
echo "KDE and its autologin configuration were not changed."
