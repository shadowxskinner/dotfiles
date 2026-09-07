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
- The `games-fullscreen` windowrule forces real fullscreen for `steam_app_*`,
  Gamescope, and the emulators. Steam launches most titles borderless, which
  Hyprland does not count as fullscreen: that single fact blocked `solitary` and
  direct scanout, kept the DMS bar drawn over the game, and stopped
  `linux-wallpaperengine`'s existing `--fullscreen-pause-only-active` from ever
  firing. One rule fixes all four. It deliberately sets only `fullscreen`, since
  `fullscreen_opacity = 1.0` then makes the window opaque and nothing blurs
  behind an opaque fullscreen window.
- New-style rule blocks accept far fewer properties than the old `windowrulev2`
  keywords. `no_border`, `no_blur`, `no_shadow` and `idle_inhibit` are all
  rejected with "config option does not exist". Verify any rule change against
  the running compositor before trusting it; Hyprland auto-reloads on save and
  banners the first bad option.
- Measured on 4K/165 before the rule: kawase blur (size 12, passes 4) cost ~3.7
  points of GPU at an idle desktop, and `linux-wallpaperengine` cost ~3.6% of GPU
  time plus 802 MiB of VRAM. `active_opacity` is 0.78, so a borderless game was
  being blurred behind every frame at 3840x2160.
- `vrr = 2` is correct and verified: the monitor reports `vrr: false` on the idle
  desktop, so the OLED flicker source is gone. In-game behaviour is unverified.
  If flicker returns in a game, cap FPS below max refresh before trying `vrr = 0`.
- `allow_tearing` stays false. With VRR working, tearing buys nothing; direct
  scanout was blocked by borderless windowing, not by the tearing setting.
- Nothing is throttling. CPU is `amd-pstate-epp` with the `powersave` governor and
  `EPP=balance_performance`, which is the normal active mode on this driver, not a
  throttle. GPU `power_dpm_force_performance_level` is `auto`.
- Games were capped at 1440p, not running at 4K. 3840x2160 at scale 1.5 gives a
  2560x1440 logical size, and XWayland hands the logical size to X11 clients:
  `xrandr` reported 2560x1440 as the *maximum* mode, so Steam and every Proton
  title rendered at 1440p and were upscaled by the compositor. `xwayland {
  force_zero_scaling = true }` addresses this. It costs X11 UI scaling, so Steam
  needs `-forcedesktopscaling 1.5`.
- `force_zero_scaling` takes effect on an explicit `hyprctl reload`; no relogin is
  needed. Hyprland's config auto-reload does not reliably fire for edits made by
  an external tool, so `hyprctl getoption xwayland:force_zero_scaling` read
  `int: 0, set: false` until reload was run by hand. Verified after reload:
  `int: 1, set: true` and `xrandr` reporting `3840x2160`.
- XWayland vs Wayland-native is what decided this, not Flatpak vs native. The
  running Wayland-native clients (`com.danklinux.dms`, `com.anthropic.Claude`,
  `kitty`) all report `xwayland: false` and were never capped. Packaging format is
  irrelevant to the resolution question; removing the Steam Flatpak would not have
  fixed it.

## Durable decisions

- Hyprland is a second SDDM session; KDE remains the fallback and Sunshine autologin target.
- Session switching uses one-shot Plasma autologin and one-shot Windows BootNext, never a lasting BootOrder or autologin change.
- Reuse the theme manager in `wayland-kde-build`; only its wallpaper backend differs by session.
- Do not push local commits without an explicit request.

## Next step

- Keep rice work in this repo separate from the Wallpaper Engine backend until other scenes are requested.
- GameMode is installed by `scripts/install-hyprland-packages.sh` but is not yet
  wired. Two steps remain, both outside this repo: copy `~/hermes/gamemode.ini`
  to `~/.config/gamemode.ini`, and add `gamemoderun %command%` to the launch
  options of each game. GameMode only activates when the game asks for it, so
  installing the package alone changes nothing. Verify with `gamemoded -s`.
- Steam is moving from the Flatpak to the native package. `gamemoderun` from the
  host cannot reach into the Flatpak sandbox, which is the main reason for the
  move. The library at `/mnt/980pro/SteamLibrary` is outside the Flatpak app dir,
  so native Steam can adopt it without redownloading. Install and verify native
  Steam first; uninstall the Flatpak only afterwards.
