# Midnight-PC dotfiles

Personal configuration for KDE, Hyprland, Kitty, Neovim, Waybar, and related tools.

## Hyprland status

Hyprland is configured alongside KDE, never as a replacement. KDE remains the fallback and the
autologin target used by Sunshine/Moonlight. Select Hyprland from SDDM only when testing locally.

The first clean baseline includes:

- the known DP-3 1440p/120 Hz layout and remembered HDMI portrait layout;
- Kitty, Dolphin, Wofi, DMS, PipeWire controls, and screenshots;
- the useful gaps, rounded corners, systemwide kawase blur, workspaces, scratchpad, and mouse bindings from the old setup;
- a Hyprland dark preference so GTK/Qt apps and browsers follow a dark color scheme.
- a 12-hour GTK clock preference, including GTK file pickers.

The duplicate Eww experiment was removed because it targeted i3, rofi, and a missing Polybar power
menu. The old `swww` startup was also removed because neither the program nor its referenced image
exists. Git history remains the recovery path for both.

## Install the tracked desktop configuration

```bash
./scripts/install-hyprland-packages.sh
./install.sh
```

Run the package script in a visible terminal so `sudo` can ask for your password. It installs tagged
packages from Arch's official repositories. The config installer backs up an existing
`~/.config/hypr` or `~/.config/waybar`, then links this repository. Neither script changes SDDM,
changes KDE, or publishes anything.

## First login

The Epomaker HE68 Mag is a 65% board: no Print Screen, no F-row, no media keys. Shortcuts below
use keys that exist. Keep the keyboard in **Windows mode** (physical Win/Mac switch, or `Fn+W`).
Mac mode makes Super arrive as Alt and every bind goes dead.

- Open applications: `Super+Space` or `Alt+Space`
- Terminal: `Super+Enter`
- Files: `Super+E`
- Close window: `Super+Q` or `Super+W`
- Exit Hyprland: `Super+Shift+Q`
- Fullscreen: `Super+F`
- Theme picker: `Super+T`
- Next / previous theme: `Super+.` / `Super+,`
- Resume the schedule: `Super+'`
- Region screenshot: `Super+P`  (saved under `~/Pictures`)
- Full screenshot: `Super+Shift+P`
- Volume up / down / mute: `Super+=` / `Super+-` / `Super+M`
- Toggle Gaming Mode: `Super+G`

Gaming Mode leaves desktop apps and Hyprland visuals untouched. It unloads active Ollama models
and stops running Hermes containers. Toggle it off to restart only the containers it stopped;
Ollama models load again automatically when an app next requests one.

The existing timed theme manager and Wofi styles live in `wayland-kde-build`. Hyprland Wallpaper
Engine rendering is enabled there through `linux-wallpaperengine`. Dragon and Reaper are the active,
verified rotation; DMS and Hyprland window borders follow `theme-set` through `hypr-theme-apply`.
DMS owns the live bar and notifications in Hyprland. The Waybar configuration stays tracked here as
an emergency rollback; start it with `hypr-waybar`. SwayNC is not part of the active setup and is not
maintained as a rollback. KDE's wallpaper and autologin paths remain unchanged.

## Verification

```bash
./scripts/check.sh
```
