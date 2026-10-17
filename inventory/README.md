# Machine inventory

Run `./scripts/capture-linux-inventory.sh` before a reinstall and after major setup changes. It
records explicit distro packages, Flatpak applications, and enabled service names under
`inventory/current/`.

The inventory is a rebuild checklist, not a disk image. It deliberately does not copy home-directory
contents, environment files, API keys, browser profiles, container volumes, game data, or save files.
Keep those in the separate backup system and verify a restore before reinstalling.

Review generated files before committing them. Package and service names can still reveal which
software the machine uses, even though the script does not collect credentials.
