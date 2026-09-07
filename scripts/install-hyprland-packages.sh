#!/usr/bin/env bash
set -euo pipefail

sudo pacman -S --needed hyprland xdg-desktop-portal-hyprland dms-shell dms-shell-hyprland waybar grim slurp hyprpolkitagent swaync wl-clipboard efibootmgr zenity

# Feral GameMode. ~/hermes/gamemode.ini and the hermes-gamemode-{start,end}.sh
# hooks were written for this but nothing was ever installed, so they had never
# run. gamemode only activates when the game asks for it, so installing this is
# necessary but not sufficient — see .ai/context.md for the two wiring steps.
# lib32-gamemode needs [multilib] enabled and is required for 32-bit titles.
sudo pacman -S --needed gamemode lib32-gamemode
