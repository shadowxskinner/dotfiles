#!/usr/bin/env bash
set -euo pipefail

repo_dir="$(cd "$(dirname "$0")/.." && pwd)"
cd "$repo_dir"

bash -n install.sh
bash -n scripts/install-hyprland-packages.sh
python3 -m json.tool .config/waybar/config >/dev/null
python3 -m py_compile .config/waybar/player-button.py .config/waybar/window-count.py \
  .config/waybar/wifi-menu .config/waybar/bluetooth-menu
bash -n scripts/gaming-mode
bash -n scripts/session-switch
bash -n scripts/midnight-session-helper
bash -n scripts/ha-lights
python3 -m json.tool .config/DankMaterialShell/plugins/GamingMode/plugin.json >/dev/null
python3 -m json.tool .config/DankMaterialShell/plugins/Lights/plugin.json >/dev/null
python3 -m json.tool .config/DankMaterialShell/plugins/SessionPower/plugin.json >/dev/null
python3 -m json.tool .config/DankMaterialShell/settings.json >/dev/null
grep -q '"showNetworkIcon": false' .config/DankMaterialShell/settings.json
grep -q '"id": "plugin_gamingMode"' .config/DankMaterialShell/settings.json
grep -q '"id": "plugin_lights"' .config/DankMaterialShell/settings.json
grep -q '"id": "plugin_sessionPower"' .config/DankMaterialShell/settings.json
if grep -E 'plugin_sessionKde|plugin_sessionWindows' .config/DankMaterialShell/settings.json; then
  echo "KDE and Windows tiles must not appear in DMS Control Center" >&2
  exit 1
fi
if [[ -e .config/DankMaterialShell/plugins/SessionKde || -e .config/DankMaterialShell/plugins/SessionWindows ]]; then
  echo "SessionKde/SessionWindows Control Center plugins must be removed" >&2
  exit 1
fi
grep -q '"capabilities": \["control-center"\]' .config/DankMaterialShell/plugins/GamingMode/plugin.json
grep -q '"capabilities": \["dankbar-widget"\]' .config/DankMaterialShell/plugins/Lights/plugin.json
grep -q '"capabilities": \["dankbar-widget"\]' .config/DankMaterialShell/plugins/SessionPower/plugin.json
if grep -q 'control-center' .config/DankMaterialShell/plugins/Lights/plugin.json \
     .config/DankMaterialShell/plugins/SessionPower/plugin.json; then
  echo "Lights and power belong on the bar/menu, not Control Center" >&2
  exit 1
fi
if grep -q 'BarPill' .config/DankMaterialShell/plugins/GamingMode/GamingModeWidget.qml; then
  echo "Gaming Mode belongs in DMS Control Center, not the bar" >&2
  exit 1
fi
if grep -q 'BootOrder' scripts/midnight-session-helper; then
  echo "session helper must not change EFI BootOrder" >&2
  exit 1
fi
grep -q -- '--bootnext' scripts/midnight-session-helper
grep -q zz-midnight-once.conf scripts/midnight-session-helper
grep -q 'session-switch menu' .config/waybar/config
grep -q 'session-switch menu' .config/hypr/hyprland.conf
grep -q 'ha-lights menu' .config/waybar/config
grep -q 'custom/lights' .config/waybar/config
grep -q '"format": "Lights"' .config/waybar/config
grep -q '"format": "Power"' .config/waybar/config
grep -q '"position": "bottom"' .config/waybar/config
grep -qE 'hypr-waybar|exec waybar' .config/hypr/hyprland.conf
if grep -qE 'bind = \$mainMod SHIFT, Q, exit' .config/hypr/hyprland.conf; then
  echo "Super+Shift+Q must open the confirming power menu" >&2
  exit 1
fi
status_out="$(scripts/session-switch status)"
grep -q '^desktop: ' <<<"$status_out"
grep -q '^windows-boot: ' <<<"$status_out"
grep -q '^helper: ' <<<"$status_out"
SESSION_SWITCH_YES=1 SESSION_SWITCH_DRY_RUN=1 scripts/session-switch windows >/dev/null
SESSION_SWITCH_YES=1 SESSION_SWITCH_DRY_RUN=1 scripts/session-switch kde >/dev/null
if scripts/midnight-session-helper --dry-run kde 2>/dev/null; then
  echo "midnight-session-helper must refuse non-root" >&2
  exit 1
fi
lights_list="$(scripts/ha-lights list)"
for mode in candlelight focus gaming light movie night; do
  grep -q "^$mode"$'\t' <<<"$lights_list"
done
if scripts/ha-lights not-a-mode >/dev/null 2>&1; then
  echo "ha-lights must reject unknown modes" >&2
  exit 1
fi
if grep -q 'entity_id' scripts/ha-lights; then
  echo "desktop lighting control must not post entity IDs" >&2
  exit 1
fi
if grep -q 'trigger.json.entity_id' homeassistant/midnight_lighting.yaml; then
  echo "lighting webhook must not accept entity IDs from the payload" >&2
  exit 1
fi
grep -q HA_WEBHOOK_LIGHTS_MODE scripts/ha-lights
grep -q '!secret midnight_pc_lights_mode' homeassistant/midnight_lighting.yaml
grep -q 'local_only: true' homeassistant/midnight_lighting.yaml
grep -q 'script.lights_gaming' homeassistant/midnight_lighting.yaml
if grep -qE '^[[:space:]]*sudo ' install.sh && ! grep -q 'INSTALL_SESSION_HELPER' install.sh; then
  echo "install.sh must not sudo-install the helper without approval" >&2
  exit 1
fi
grep -q INSTALL_SESSION_HELPER install.sh
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
                .config/DankMaterialShell/plugins/Lights/plugin.json \
                .config/DankMaterialShell/plugins/Lights/LightsWidget.qml \
                .config/DankMaterialShell/plugins/SessionPower/plugin.json \
                .config/DankMaterialShell/plugins/SessionPower/SessionPowerWidget.qml \
                polkit/org.midnight.session-switch.policy \
                homeassistant/midnight_lighting.yaml \
                scripts/gaming-mode scripts/session-switch scripts/midnight-session-helper \
                scripts/ha-lights AGENTS.md .ai/context.md; do
  [[ -f "$required" ]] || { echo "Missing $required" >&2; exit 1; }
done

for stale in .config/eww eww; do
  [[ ! -e "$stale" ]] || { echo "Stale $stale still exists" >&2; exit 1; }
done

echo "Static checks passed."
