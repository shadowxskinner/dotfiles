#!/usr/bin/env bash
set -euo pipefail

echo "==> Starting macOS setup"

if ! command -v brew >/dev/null 2>&1; then
  echo "Homebrew is not installed."
  echo "Install it first with:"
  echo '/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"'
  exit 1
fi

echo "==> Installing core tools"
brew install git gh

echo "==> Checking GitHub auth"
if ! gh auth status >/dev/null 2>&1; then
  gh auth login
fi

DOTFILES_DIR="$HOME/dotfiles"

if [ ! -d "$DOTFILES_DIR/.git" ]; then
  echo "==> Cloning dotfiles repo"
  gh repo clone shadowxskinner/dotfiles "$DOTFILES_DIR"
else
  echo "==> Dotfiles repo already exists, pulling latest changes"
  git -C "$DOTFILES_DIR" pull
fi

cd "$DOTFILES_DIR"

if [ -f Brewfile ]; then
  echo "==> Installing Homebrew packages from Brewfile"
  brew bundle --file=Brewfile
fi

mkdir -p "$HOME/.config"

backup_dir="$HOME/.config_backup_$(date +%F-%H%M)"

link_config() {
  local name="$1"
  local src="$DOTFILES_DIR/.config/$name"
  local dst="$HOME/.config/$name"

  if [ ! -e "$src" ]; then
    echo "==> Skipping $name (not found in repo)"
    return
  fi

  if [ -e "$dst" ] && [ ! -L "$dst" ]; then
    echo "==> Backing up $dst to $backup_dir/$name"
    mkdir -p "$backup_dir"
    mv "$dst" "$backup_dir/$name"
  fi

  ln -snf "$src" "$dst"
  echo "==> Linked $dst -> $src"
}

echo "==> Linking configs"
link_config kitty
link_config nvim

if [ -f "$DOTFILES_DIR/.zshrc" ]; then
  if [ -f "$HOME/.zshrc" ] && [ ! -L "$HOME/.zshrc" ]; then
    mkdir -p "$backup_dir"
    cp "$HOME/.zshrc" "$backup_dir/.zshrc"
  fi
  ln -snf "$DOTFILES_DIR/.zshrc" "$HOME/.zshrc"
  echo "==> Linked ~/.zshrc -> $DOTFILES_DIR/.zshrc"
fi

echo "==> Setup complete"
echo "Restart terminal or run: source ~/.zshrc"
