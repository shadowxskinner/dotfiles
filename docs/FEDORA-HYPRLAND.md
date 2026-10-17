# Fedora + Hyprland rebuild

This is the recovery path for a future clean Fedora installation with Hyprland as the only desktop.
It does not remove KDE or alter the current Arch installation. The existing Arch installer remains
Arch-specific and must not be run on Fedora.

## Before reinstalling

1. Run `./scripts/capture-linux-inventory.sh` and review the generated files.
2. Commit or export every wanted project, including any uncommitted dotfile changes.
3. Back up and test-restore Documents, Pictures, game saves, container volumes, SSH material, and
   browser data. A file existing in a backup is not proof that it restores correctly.
4. Copy secrets separately. Never commit `~/.config/triage-watch.env`, `~/.config/ha-pc.env`, Hermes
   authentication, Docker `.env` files, private keys, or tokens.
5. Record storage and boot layouts. Keep a bootable Fedora USB and the current recovery media until
   the rebuilt machine has passed every check below.

## Minimal Fedora desktop

On the current stable Fedora release, begin with packages from Fedora's repositories:

```bash
sudo dnf install hyprland xdg-desktop-portal-hyprland waybar kitty sddm \
  grim slurp wl-clipboard
```

Package availability and names must be checked again at migration time. Start with Waybar and a
static wallpaper. Walker, DankMaterialShell, Wallpaper Engine integration, and other community-built
layers are optional follow-up work, not prerequisites for a usable desktop.

Clone this repository, then port only the portable configuration first. Do not run `install.sh` or
`scripts/install-hyprland-packages.sh` on Fedora: they assume pacman, Arch package names, KDE fallback,
and this machine's current one-shot session switching.

## Restore order

1. Graphics, displays, keyboard, audio, network, and the Hyprland portal.
2. Kitty, launcher, notifications, screenshots, clipboard, and screen locking.
3. User files and project repositories.
4. Tailscale/firewall rules and Sunshine/Moonlight capture under Hyprland.
5. Docker, Hermes, watchdogs, Home Assistant hooks, and local models.
6. Steam, compatibility tools, emulators, ROM libraries, and verified save restores.
7. Themes, DMS, Walker, Wallpaper Engine, and other appearance extras.

Restore secrets only when their owning service is ready. Re-create service definitions from tracked
configuration, then add credentials locally with restrictive permissions.

## Acceptance checks

- Hyprland starts from SDDM and survives a reboot without a second desktop installed.
- Screen sharing and file pickers use the Hyprland portal.
- AMD graphics, both monitor layouts, PipeWire audio, Bluetooth, and the HE68 keyboard work.
- Sunshine can capture the Hyprland session and Moonlight input works.
- Hermes and watchdog services are healthy, do not loop notifications, and recover after reboot.
- Gaming Mode pauses and restores only the intended local services.
- Personal files and at least one representative game save restore from backup.
- `./scripts/check.sh` passes after Fedora-specific assumptions have been separated from Arch ones.

Do not erase the old installation or its recovery media until these checks pass and a fresh backup of
the Fedora system has been tested.
