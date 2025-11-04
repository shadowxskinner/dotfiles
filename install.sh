#!/usr/bin/env bash
set -euo pipefail
backup="$HOME/.config_backup_$(date +%F-%H%M)"
mkdir -p "$backup"

deploy() {
  src="$HOME/dotfiles/.config/$1"
  dst="$HOME/.config/$1"
  if [ -e "$dst" ] && [ ! -L "$dst" ]; then
    echo "Backing up $dst -> $backup/$1"
    mkdir -p "$(dirname "$backup/$1")"
    mv "$dst" "$backup/$1"
  fi
  mkdir -p "$(dirname "$dst")"
  ln -snf "$src" "$dst"
  echo "Linked $dst -> $src"
}

for dir in kitty nvim hypr waybar; do
  [ -d "$HOME/dotfiles/.config/$dir" ] && deploy "$dir"
done
echo "Done."
