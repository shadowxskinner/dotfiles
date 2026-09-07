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

deploy_file() {
  local rel="$1" src="$repo_dir/.config/$1" dst="$HOME/.config/$1"
  [[ -f "$src" ]] || { echo "Missing source: $src" >&2; return 1; }
  mkdir -p "$(dirname "$dst")"
  if [[ -e "$dst" || -L "$dst" ]]; then
    mkdir -p "$backup"
    mv "$dst" "$backup/${rel//\//_}"
    echo "Backed up $dst to $backup/${rel//\//_}"
  fi
  ln -sfn "$src" "$dst"
  echo "Linked $dst -> $src"
}

mkdir -p "$HOME/.config" "$HOME/.local/bin"
install -Dm755 "$repo_dir/scripts/gaming-mode" "$HOME/.local/bin/gaming-mode"
install -Dm755 "$repo_dir/scripts/session-switch" "$HOME/.local/bin/session-switch"
install -Dm644 "$repo_dir/.config/systemd/user/gaming-mode-watch.service" \
  "$HOME/.config/systemd/user/gaming-mode-watch.service"
install -Dm644 "$repo_dir/.config/DankMaterialShell/plugins/GamingMode/plugin.json" \
  "$HOME/.config/DankMaterialShell/plugins/GamingMode/plugin.json"
install -Dm644 "$repo_dir/.config/DankMaterialShell/plugins/GamingMode/GamingModeWidget.qml" \
  "$HOME/.config/DankMaterialShell/plugins/GamingMode/GamingModeWidget.qml"
install -Dm644 "$repo_dir/.config/DankMaterialShell/plugins/SessionKde/plugin.json" \
  "$HOME/.config/DankMaterialShell/plugins/SessionKde/plugin.json"
install -Dm644 "$repo_dir/.config/DankMaterialShell/plugins/SessionKde/SessionKdeWidget.qml" \
  "$HOME/.config/DankMaterialShell/plugins/SessionKde/SessionKdeWidget.qml"
install -Dm644 "$repo_dir/.config/DankMaterialShell/plugins/SessionWindows/plugin.json" \
  "$HOME/.config/DankMaterialShell/plugins/SessionWindows/plugin.json"
install -Dm644 "$repo_dir/.config/DankMaterialShell/plugins/SessionWindows/SessionWindowsWidget.qml" \
  "$HOME/.config/DankMaterialShell/plugins/SessionWindows/SessionWindowsWidget.qml"
if ! cmp -s "$repo_dir/.config/DankMaterialShell/settings.json" \
             "$HOME/.config/DankMaterialShell/settings.json"; then
  if [[ -f "$HOME/.config/DankMaterialShell/settings.json" ]]; then
    mkdir -p "$backup"
    cp -a "$HOME/.config/DankMaterialShell/settings.json" "$backup/DankMaterialShell-settings.json"
  fi
  install -Dm644 "$repo_dir/.config/DankMaterialShell/settings.json" \
    "$HOME/.config/DankMaterialShell/settings.json"
fi
systemctl --user daemon-reload
systemctl --user enable --now gaming-mode-watch.service
if command -v dms >/dev/null; then
  dms ipc plugin-scan scan >/dev/null || true
  dms ipc call plugins enable gamingMode >/dev/null || true
  dms ipc call plugins enable sessionKde >/dev/null || true
  dms ipc call plugins enable sessionWindows >/dev/null || true
fi

echo "Installing the session-switch helper (needs sudo for pkexec / polkit)."
sudo install -o root -g root -m755 "$repo_dir/scripts/midnight-session-helper" \
  /usr/local/bin/midnight-session-helper
sudo install -o root -g root -m644 "$repo_dir/polkit/org.midnight.session-switch.policy" \
  /usr/share/polkit-1/actions/org.midnight.session-switch.policy

mkdir -p "$HOME/.config"
deploy hypr
deploy waybar
deploy_file gtk-3.0/settings.ini
deploy_file gtk-4.0/settings.ini
deploy_file xdg-desktop-portal/hyprland-portals.conf

echo "Configuration installed. Log out and select Hyprland in SDDM."
echo "KDE and its autologin configuration were not changed."
echo "session-switch can one-shot Plasma for Moonlight or Windows 11 without changing BootOrder."
