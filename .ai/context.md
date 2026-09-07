# Shared project context

## Purpose

Reproducible Midnight-PC desktop configuration, including a clean Hyprland session alongside KDE.

## Current status

- Existing public GitHub dotfiles were recovered to `/home/shadow/Projects/dotfiles`.
- Hyprland 0.56.2 is a second SDDM session; KDE remains the fallback and Sunshine autologin target.
- The Hyprland config exports `WAYLAND_DISPLAY`, `XDG_CURRENT_DESKTOP`, `XDG_SESSION_TYPE`, and
  `HYPRLAND_INSTANCE_SIGNATURE` into the systemd user environment.
- Wallpaper Engine on Hyprland lives in `wayland-kde-build`, not this repo. Dragon and Reaper are
  the active, verified rotation; Night City is installed but intentionally inactive.
- Wofi is a compact overlay launcher. Hyprland disables `close_on_focus_loss` so the menu can keep focus.
- DMS owns the Hyprland bar and notifications. Its custom Dragon/Reaper palette follows `theme-set`.
  The tracked Waybar configuration remains as an emergency rollback only, launched by `hypr-waybar`.
  SwayNC is not part of the active setup: no `~/.config/swaync` is tracked or deployed, and its
  Hyprland layer rules were removed. The package may still be installed, which is harmless.
- Hyprland uses strong kawase blur with slightly transparent windows so the wallpaper frosts through. Fullscreen stays opaque.
- Hyprland asks GTK, Qt, and xdg-desktop-portal for dark style (`prefer-dark`) and uses a 12-hour GTK clock. KDE already uses Breeze Dark; this does not change SDDM.
- Window borders follow `theme-set`: Dragon red, Reaper grey. `hypr-theme-apply` runs on Hyprland start and reload so Reaper cannot keep a leftover Dragon border.
- `gaming-mode-watch.service` listens to Hyprland window events and activates Gaming Mode for Steam/Lutris games, Gamescope, PCSX2, RPCS3, Dolphin, RetroArch, DuckStation, Xemu, Cemu, Ryujinx, Yuzu, and Suyu. It restores only recorded Hermes containers after the last game closes. `Super+G` remains a manual override, apps and visual effects stay open, and the DMS Control Center tile reflects the same state without occupying the bar. Home Assistant webhook IDs come from the local mode-600 `~/.config/ha-pc.env`, never Git.
- `session-switch` is the Bazzite-style picker: DMS Control Center tiles, Waybar ⇄, and `Super+K`. KDE is a one-shot SDDM Plasma login for Sunshine/Moonlight. Windows 11 is EFI BootNext only; BootOrder stays Linux-first. Lasting SDDM autologin is unchanged.
- Hyprland binds are HE68-shaped: no Print/F-row/media keys. Screenshots are Super+P / Super+Shift+P. Volume is Super+= / Super+-. Session switch is Super+K. Windows mode required (Fn+W).

## Durable decisions

- Hyprland is a second SDDM session; KDE remains the fallback and Sunshine autologin target.
- Session switching uses one-shot Plasma autologin and one-shot Windows BootNext, never a lasting BootOrder or autologin change.
- Reuse the theme manager in `wayland-kde-build`; only its wallpaper backend differs by session.
- Do not push local commits without an explicit request.

## Next step

- Keep rice work in this repo separate from the Wallpaper Engine backend until other scenes are requested.
