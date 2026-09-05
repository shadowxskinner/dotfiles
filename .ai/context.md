# Shared project context

## Purpose

Reproducible Midnight-PC desktop configuration, including a clean Hyprland session alongside KDE.

## Current status

- Existing public GitHub dotfiles were recovered to `/home/shadow/Projects/dotfiles`.
- The old Hyprland sample was reduced to a minimal machine-specific baseline.
- Duplicate Eww experiments and broken `swww` startup were removed with Git recovery preserved.
- KDE and the existing Wallpaper Engine integration remain unchanged.

## Durable decisions

- Hyprland is a second SDDM session; KDE remains the fallback and Sunshine autologin target.
- Reuse the theme manager in `wayland-kde-build`; only its wallpaper backend should differ by session.
- Do not select a Hyprland Wallpaper Engine backend until it can be tested in a live Hyprland session.

## Next step

- Install the official Hyprland baseline packages, deploy the links, and perform one local login smoke test.
