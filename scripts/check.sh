#!/usr/bin/env bash
set -euo pipefail

repo_dir="$(cd "$(dirname "$0")/.." && pwd)"
cd "$repo_dir"

bash -n install.sh
bash -n scripts/install-hyprland-packages.sh
python -m json.tool .config/waybar/config >/dev/null
python3 -m py_compile .config/waybar/player-button.py .config/waybar/window-count.py \
  .config/waybar/wifi-menu .config/waybar/bluetooth-menu
git diff --check

if command -v Hyprland >/dev/null; then
  Hyprland --verify-config -c "$repo_dir/.config/hypr/hyprland.conf"
fi

for required in .config/hypr/hyprland.conf .config/waybar/config .config/waybar/style.css \
                .config/waybar/themes/dragon.css .config/waybar/themes/reaper.css \
                .config/gtk-3.0/settings.ini \
                .config/gtk-4.0/settings.ini \
                .config/xdg-desktop-portal/hyprland-portals.conf \
                AGENTS.md .ai/context.md; do
  [[ -f "$required" ]] || { echo "Missing $required" >&2; exit 1; }
done

for stale in .config/eww eww; do
  [[ ! -e "$stale" ]] || { echo "Stale $stale still exists" >&2; exit 1; }
done

echo "Static checks passed."
