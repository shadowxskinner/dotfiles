#!/usr/bin/env bash
# Install Walker + elephant and the six providers this desktop uses.
#
# AUR EXCEPTION, DELIBERATE. AGENTS.md says to prefer official Arch packages and
# avoid AUR. Walker and elephant are not in the official repos at all, so there
# is no official path to take; this is not a rice bundle and nothing here is a
# -git package. The Hyprland baseline itself is untouched.
#
# Idempotent: safe to re-run. Installs nothing already present, and never
# starts or restarts elephant behind your back -- enabling the user service is
# the last step and it is announced.
set -euo pipefail

repo_dir="$(cd "$(dirname "$0")/.." && pwd)"
doc_dir="$repo_dir/docs/elephant"

if [[ "${EUID}" -eq 0 ]]; then
  echo "Run this as your user, not root: it enables a --user systemd unit." >&2
  exit 1
fi

helper=""
for h in yay paru; do
  if command -v "$h" >/dev/null 2>&1; then helper="$h"; break; fi
done
if [[ -z "$helper" ]]; then
  echo "Need an AUR helper (yay or paru). Neither is installed." >&2
  exit 1
fi

# Official repos. Each is a real runtime dependency, not a nicety:
#   gtk4, gtk4-layer-shell  Walker's toolkit and its layer-shell surface.
#   libqalculate            the calc provider shells out to qalc.
#   wl-clipboard            the clipboard provider runs `wl-paste --watch`.
#   imagemagick             the clipboard provider runs `identify` on images.
# The last two matter more than they look: clipboard's Available() check
# disables the provider SILENTLY if either binary is missing. No error, no entry
# in the provider list -- the `:` prefix simply returns nothing.
official=(gtk4 gtk4-layer-shell libqalculate wl-clipboard imagemagick)

missing_official=()
for p in "${official[@]}"; do
  pacman -Qq "$p" >/dev/null 2>&1 || missing_official+=("$p")
done
if ((${#missing_official[@]})); then
  echo "Installing from official repos: ${missing_official[*]}"
  sudo pacman -S --needed "${missing_official[@]}"
else
  echo "Official dependencies already present."
fi

# AUR. providerlist is not one of the six requested providers but Walker needs
# it for the `;` provider switcher and upstream treats it as mandatory.
aur=(
  walker
  elephant
  elephant-providerlist
  elephant-desktopapplications
  elephant-clipboard
  elephant-calc
  elephant-windows
  elephant-menus
  elephant-runner
)

# Package names are checked rather than assumed. The AUR is now behind Anubis,
# so the naming could not be confirmed from the web at authoring time; the
# elephant-<provider> pattern comes from upstream's own README. If a name has
# drifted, this reports it instead of failing halfway through an install.
echo "Checking AUR package names..."
unknown=()
for p in "${aur[@]}"; do
  "$helper" -Si "$p" >/dev/null 2>&1 || unknown+=("$p")
done
if ((${#unknown[@]})); then
  echo >&2
  echo "These package names do not resolve: ${unknown[*]}" >&2
  echo "Search for the current names with: $helper -Ss elephant" >&2
  echo "Nothing was installed." >&2
  exit 1
fi

missing_aur=()
for p in "${aur[@]}"; do
  pacman -Qq "$p" >/dev/null 2>&1 || missing_aur+=("$p")
done
if ((${#missing_aur[@]})); then
  echo "Installing from the AUR: ${missing_aur[*]}"
  "$helper" -S --needed "${missing_aur[@]}"
else
  echo "Walker, elephant and all providers already installed."
fi

# Record the config schema of the versions actually on disk. elephant ignores
# unrecognised keys silently, so a config that no longer matches the binary
# fails invisibly; this is how you tell.
echo "Writing elephant config docs to ${doc_dir#"$repo_dir"/}/ ..."
mkdir -p "$doc_dir"
elephant generatedoc >"$doc_dir/elephant.md" 2>/dev/null || true
for p in desktopapplications clipboard calc windows menus runner; do
  elephant generatedoc "$p" >"$doc_dir/$p.md" 2>/dev/null || true
done

# Service last, and announced. `elephant service enable` writes
# ~/.config/systemd/user/elephant.service but deliberately does not start it.
#
# USER SERVICE, NOT SYSTEM. elephant's README is emphatic: it needs the user's
# environment (WAYLAND_DISPLAY, XDG_CURRENT_DESKTOP, the Hyprland instance
# signature). hyprland.lua already pushes those into the systemd user
# environment via dbus-update-activation-environment at session start, so a
# --user unit inherits them. A system unit would start with none of it and the
# clipboard and windows providers would come up dead.
echo
echo "Enabling the elephant user service."
elephant service enable
systemctl --user daemon-reload
systemctl --user enable --now elephant.service
systemctl --user --no-pager status elephant.service --lines=0 || true

echo
echo "Installed. Next: ./install.sh to deploy the walker and elephant configs."
echo "Then verify the layer namespace, which the blur rule depends on:"
echo "  hyprctl layers | grep -i -B2 walker"
