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
bash -n scripts/session-switch
bash -n scripts/midnight-session-helper
python -m json.tool .config/DankMaterialShell/plugins/GamingMode/plugin.json >/dev/null
python -m json.tool .config/DankMaterialShell/plugins/SessionKde/plugin.json >/dev/null
python -m json.tool .config/DankMaterialShell/plugins/SessionWindows/plugin.json >/dev/null
python -m json.tool .config/DankMaterialShell/settings.json >/dev/null
grep -q '"showNetworkIcon": false' .config/DankMaterialShell/settings.json
grep -q '"id": "plugin_gamingMode"' .config/DankMaterialShell/settings.json
grep -q '"id": "plugin_sessionKde"' .config/DankMaterialShell/settings.json
grep -q '"id": "plugin_sessionWindows"' .config/DankMaterialShell/settings.json
grep -q '/home/shadow/.local/bin/gaming-mode' \
  .config/DankMaterialShell/plugins/GamingMode/GamingModeWidget.qml
grep -q '"capabilities": \["control-center"\]' .config/DankMaterialShell/plugins/SessionKde/plugin.json
grep -q '"capabilities": \["control-center"\]' .config/DankMaterialShell/plugins/SessionWindows/plugin.json
if grep -q 'BarPill' .config/DankMaterialShell/plugins/GamingMode/GamingModeWidget.qml \
     .config/DankMaterialShell/plugins/SessionKde/SessionKdeWidget.qml \
     .config/DankMaterialShell/plugins/SessionWindows/SessionWindowsWidget.qml; then
  echo "Session actions belong in DMS Control Center, not the bar" >&2
  exit 1
fi
if grep -q 'BootOrder' scripts/midnight-session-helper; then
  echo "session helper must not change EFI BootOrder" >&2
  exit 1
fi
grep -q -- '--bootnext' scripts/midnight-session-helper
grep -q zz-midnight-once.conf scripts/midnight-session-helper
status_out="$(scripts/session-switch status)"
grep -q '^desktop: ' <<<"$status_out"
grep -q '^windows-boot: ' <<<"$status_out"
grep -q '^helper: ' <<<"$status_out"
SESSION_SWITCH_YES=1 SESSION_SWITCH_DRY_RUN=1 scripts/session-switch windows >/dev/null
if scripts/midnight-session-helper --dry-run kde 2>/dev/null; then
  echo "midnight-session-helper must refuse non-root" >&2
  exit 1
fi
if grep -q 'custom/session' .config/waybar/config && ! grep -q 'session-switch menu' .config/waybar/config; then
  echo "Waybar session module must call session-switch menu" >&2
  exit 1
fi
grep -q 'session-switch menu' .config/waybar/config
grep -q 'session-switch menu' .config/hypr/hyprland.conf
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
                .config/DankMaterialShell/plugins/SessionKde/plugin.json \
                .config/DankMaterialShell/plugins/SessionKde/SessionKdeWidget.qml \
                .config/DankMaterialShell/plugins/SessionWindows/plugin.json \
                .config/DankMaterialShell/plugins/SessionWindows/SessionWindowsWidget.qml \
                polkit/org.midnight.session-switch.policy \
                scripts/gaming-mode scripts/session-switch scripts/midnight-session-helper \
                AGENTS.md .ai/context.md; do
  [[ -f "$required" ]] || { echo "Missing $required" >&2; exit 1; }
done

for stale in .config/eww eww; do
  [[ ! -e "$stale" ]] || { echo "Stale $stale still exists" >&2; exit 1; }
done

echo "Static checks passed."
