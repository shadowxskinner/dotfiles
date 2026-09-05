# Midnight-PC dotfiles

Personal configuration for KDE, Hyprland, Kitty, Neovim, Waybar, and related tools.

## Hyprland status

Hyprland is configured alongside KDE, never as a replacement. KDE remains the fallback and the
autologin target used by Sunshine/Moonlight. Select Hyprland from SDDM only when testing locally.

The first clean baseline includes:

- the known DP-3 1440p/120 Hz layout and remembered HDMI portrait layout;
- Kitty, Dolphin, Wofi, Waybar, SwayNC, PipeWire controls, and screenshots;
- the useful gaps, rounded corners, blur, workspaces, scratchpad, and mouse bindings from the old setup.

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

- Open applications: `Super+Space` or `Alt+Space`
- Terminal: `Super+Enter`
- Files: `Super+E`
- Close window: `Super+W`
- Exit Hyprland: `Super+Shift+Q`
- Screenshot a region: `Super+Shift+4`

The existing timed theme manager and Wofi styles are preserved in `wayland-kde-build`. Wallpaper
Engine rendering under Hyprland is intentionally not enabled until a renderer is selected and tested
against the existing Workshop scenes. The KDE wallpaper path remains unchanged.

## Verification

```bash
./scripts/check.sh
```
