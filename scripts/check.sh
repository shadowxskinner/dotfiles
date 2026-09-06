#!/usr/bin/env bash
set -euo pipefail

repo_dir="$(cd "$(dirname "$0")/.." && pwd)"
cd "$repo_dir"

bash -n install.sh
bash -n scripts/install-hyprland-packages.sh
python -m json.tool .config/waybar/config >/dev/null
python3 -m py_compile .config/waybar/player-button.py .config/waybar/window-count.py \
  .config/waybar/wifi-menu .config/waybar/bluetooth-menu
bash -n scripts/gaming-mode
python -m json.tool .config/DankMaterialShell/plugins/GamingMode/plugin.json >/dev/null
grep -q '"capabilities": \["control-center"\]' .config/DankMaterialShell/plugins/GamingMode/plugin.json
if grep -q 'BarPill' .config/DankMaterialShell/plugins/GamingMode/GamingModeWidget.qml; then
  echo "Gaming Mode belongs in DMS Control Center, not the bar" >&2
  exit 1
fi
grep -q 'hermes-gateway' scripts/gaming-mode
grep -q 'hermes-dashboard' scripts/gaming-mode
if grep -q openwebui scripts/gaming-mode; then
  echo "OpenWebUI is retired and must not appear in gaming-mode" >&2
  exit 1
fi
for stale_id in midnight_pc_stats midnight_gaming_start midnight_gaming_end; do
  if grep -q "$stale_id" scripts/gaming-mode; then
    echo "Stale webhook id $stale_id must not appear in gaming-mode" >&2
    exit 1
  fi
done
grep -q ha-pc.env scripts/gaming-mode
test_state="$(mktemp -d)"
trap 'rm -rf "$test_state"' EXIT
[[ "$(XDG_STATE_HOME="$test_state" scripts/gaming-mode status)" == off ]]
mkdir -p "$test_state/midnight-gaming-mode"
touch "$test_state/midnight-gaming-mode/active"
[[ "$(XDG_STATE_HOME="$test_state" scripts/gaming-mode status)" == on ]]
rm -rf "$test_state"
trap - EXIT

test_state="$(mktemp -d)"
trap 'rm -rf "$test_state"' EXIT
mkdir -p "$test_state/bin"
for command_name in docker ollama curl notify-send; do
  printf '#!/usr/bin/env bash\nexit 0\n' >"$test_state/bin/$command_name"
  chmod +x "$test_state/bin/$command_name"
done
game_json='[{"mapped":true,"initialClass":"steam_app_123","initialTitle":"Test Game","pid":0}]'
plain_json='[{"mapped":true,"initialClass":"steam","initialTitle":"Steam","pid":0}]'
[[ "$(GAMING_MODE_CLIENTS_JSON="$game_json" scripts/gaming-mode detect)" == "Test Game" ]]
PATH="$test_state/bin:$PATH" XDG_STATE_HOME="$test_state/state" HA_PC_ENV=/dev/null \
  GAMING_MODE_CLIENTS_JSON="$game_json" scripts/gaming-mode auto-sync
[[ "$(XDG_STATE_HOME="$test_state/state" scripts/gaming-mode status)" == on ]]
grep -q 'Gaming Mode: automatic' <(XDG_STATE_HOME="$test_state/state" scripts/gaming-mode details)
PATH="$test_state/bin:$PATH" XDG_STATE_HOME="$test_state/state" HA_PC_ENV=/dev/null \
  GAMING_MODE_CLIENTS_JSON="$plain_json" scripts/gaming-mode auto-sync
[[ "$(XDG_STATE_HOME="$test_state/state" scripts/gaming-mode status)" == off ]]
PATH="$test_state/bin:$PATH" XDG_STATE_HOME="$test_state/state" HA_PC_ENV=/dev/null \
  GAMING_MODE_CLIENTS_JSON="$game_json" scripts/gaming-mode auto-sync
PATH="$test_state/bin:$PATH" XDG_STATE_HOME="$test_state/state" HA_PC_ENV=/dev/null \
  scripts/gaming-mode off >/dev/null
PATH="$test_state/bin:$PATH" XDG_STATE_HOME="$test_state/state" HA_PC_ENV=/dev/null \
  GAMING_MODE_CLIENTS_JSON="$game_json" scripts/gaming-mode auto-sync
[[ "$(XDG_STATE_HOME="$test_state/state" scripts/gaming-mode status)" == off ]]
grep -q 'Gaming Mode: off (manual override)' <(XDG_STATE_HOME="$test_state/state" scripts/gaming-mode details)
PATH="$test_state/bin:$PATH" XDG_STATE_HOME="$test_state/state" HA_PC_ENV=/dev/null \
  scripts/gaming-mode on >/dev/null
PATH="$test_state/bin:$PATH" XDG_STATE_HOME="$test_state/state" HA_PC_ENV=/dev/null \
  GAMING_MODE_CLIENTS_JSON="$plain_json" scripts/gaming-mode auto-sync
[[ "$(XDG_STATE_HOME="$test_state/state" scripts/gaming-mode status)" == on ]]
PATH="$test_state/bin:$PATH" XDG_STATE_HOME="$test_state/state" HA_PC_ENV=/dev/null \
  scripts/gaming-mode off >/dev/null
[[ "$(XDG_STATE_HOME="$test_state/state" scripts/gaming-mode status)" == off ]]
rm -rf "$test_state"
trap - EXIT
git diff --check

if command -v Hyprland >/dev/null; then
  Hyprland --verify-config -c "$repo_dir/.config/hypr/hyprland.conf"
fi

for required in .config/hypr/hyprland.conf .config/waybar/config .config/waybar/style.css \
                .config/waybar/themes/dragon.css .config/waybar/themes/reaper.css \
                .config/gtk-3.0/settings.ini \
                .config/gtk-4.0/settings.ini \
                .config/xdg-desktop-portal/hyprland-portals.conf \
                .config/systemd/user/gaming-mode-watch.service \
                .config/DankMaterialShell/plugins/GamingMode/plugin.json \
                .config/DankMaterialShell/plugins/GamingMode/GamingModeWidget.qml \
                scripts/gaming-mode AGENTS.md .ai/context.md; do
  [[ -f "$required" ]] || { echo "Missing $required" >&2; exit 1; }
done

for stale in .config/eww eww; do
  [[ ! -e "$stale" ]] || { echo "Stale $stale still exists" >&2; exit 1; }
done

echo "Static checks passed."
