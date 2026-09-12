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
bash -n scripts/install-walker-packages.sh
sh -n scripts/walker-toggle

# Walker/elephant config must parse. tomllib is stdlib from 3.11; Arch is well
# past that. Fail loudly rather than skipping if it is somehow missing.
python3 - <<'EOF'
import glob
import tomllib
for f in sorted(
    glob.glob(".config/walker/*.toml")
    + glob.glob(".config/elephant/*.toml")
    + glob.glob(".config/elephant/menus/*.toml")
):
    with open(f, "rb") as fh:
        tomllib.load(fh)
EOF

# The session menu must call session-switch's real subcommands, not re-implement
# efibootmgr or pkexec. If an entry ever stops shelling out to session-switch,
# the one-shot BootNext guarantees have been forked.
grep -q 'session-switch kde' .config/elephant/menus/session.toml
grep -q 'session-switch windows' .config/elephant/menus/session.toml
# Comments are stripped first: the file's header explains the BootNext/pkexec
# behaviour it is deliberately NOT reimplementing, and grepping the raw file
# matches that prose and fails on a correct config.
if sed 's/#.*//' .config/elephant/menus/session.toml |
    grep -qE 'efibootmgr|pkexec|BootNext'; then
  echo "Session menu must delegate to session-switch, not reimplement it" >&2
  exit 1
fi

# Wofi stays the fallback launcher. All three of these are the fallback path:
# the Walker bind, the explicit wofi bind, and walker-toggle's own handoff.
grep -q 'walker-toggle' .config/hypr/hyprland.lua
grep -q 'wofi-toggle' .config/hypr/hyprland.lua
grep -q 'wofi-toggle' scripts/walker-toggle
grep -q 'session-switch menu' .config/hypr/hyprland.lua
# walker-toggle only ever reads theme-manager state, same contract as
# wofi-toggle and hypr-theme-apply.
if grep -qE '>[[:space:]]*"?\$STATE_DIR|write_state|mv .*STATE_DIR' scripts/walker-toggle; then
  echo "walker-toggle must not write theme-manager state" >&2
  exit 1
fi
# The blur rule is namespace-matched and silently does nothing if the namespace
# is wrong; at minimum make sure the rule did not get dropped.
grep -q 'walker-chrome' .config/hypr/hyprland.lua

# elephant must not regress to the generated unit. Both guards matter: the
# condition is what stops it starting blind on a cold boot, and the restart in
# hyprland.lua is what starts it once the environment exists. Either one alone
# leaves Walker showing "Waiting for elephant..." after a reboot.
grep -q 'ConditionEnvironment=WAYLAND_DISPLAY' .config/systemd/user/elephant.service
grep -q 'Restart=always' .config/systemd/user/elephant.service
grep -q 'systemctl --user restart elephant.service' .config/hypr/hyprland.lua
# The restart is useless before the environment is exported. Fail if the order
# is ever swapped.
#
# Both patterns must match exactly one line. Anchoring on hl.exec_cmd( is what
# does that: the surrounding comments mention both commands by name, and a
# looser grep returns two line numbers, which then fails the integer test with
# "334\n337: integer expression expected" rather than reporting a real problem.
hypr_line() { grep -n "hl\.exec_cmd(\"$1" .config/hypr/hyprland.lua | head -1 | cut -d: -f1; }
dbus_at="$(hypr_line 'dbus-update-activation-environment')"
elephant_at="$(hypr_line 'systemctl --user restart elephant.service')"
if [[ -z "$dbus_at" || -z "$elephant_at" ]]; then
  echo "could not locate the autostart lines in hyprland.lua" >&2
  exit 1
fi
if (( dbus_at > elephant_at )); then
  echo "elephant restart must come AFTER dbus-update-activation-environment" >&2
  exit 1
fi
# install-walker-packages.sh must not regenerate the weaker unit.
if grep -qE '^\s*elephant service enable' scripts/install-walker-packages.sh; then
  echo "install-walker-packages.sh must not run 'elephant service enable'" >&2
  exit 1
fi
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
                .config/systemd/user/elephant.service \
                .config/DankMaterialShell/plugins/GamingMode/plugin.json \
                .config/DankMaterialShell/plugins/GamingMode/GamingModeWidget.qml \
                .config/DankMaterialShell/plugins/SessionKde/plugin.json \
                .config/DankMaterialShell/plugins/SessionKde/SessionKdeWidget.qml \
                .config/DankMaterialShell/plugins/SessionWindows/plugin.json \
                .config/DankMaterialShell/plugins/SessionWindows/SessionWindowsWidget.qml \
                polkit/org.midnight.session-switch.policy \
                .config/walker/config.toml \
                .config/walker/themes/yours/style.css \
                .config/walker/themes/dragon/style.css \
                .config/walker/themes/reaper/style.css \
                .config/elephant/elephant.toml \
                .config/elephant/menus/session.toml \
                scripts/gaming-mode scripts/session-switch scripts/midnight-session-helper \
                scripts/walker-toggle scripts/install-walker-packages.sh \
                AGENTS.md .ai/context.md; do
  [[ -f "$required" ]] || { echo "Missing $required" >&2; exit 1; }
done

for stale in .config/eww eww; do
  [[ ! -e "$stale" ]] || { echo "Stale $stale still exists" >&2; exit 1; }
done

echo "Static checks passed."
