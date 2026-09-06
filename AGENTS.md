# Dotfiles agent instructions

- Read `README.md`, `.ai/context.md`, Git status, and recent commits before editing.
- Preserve KDE as a working fallback and keep SDDM autologin pointed at Plasma for Sunshine.
- Treat `wayland-kde-build` as the authority for the existing theme manager and Wallpaper Engine IDs.
- Never deploy an unverified config, overwrite live configuration without a backup, or change boot/login settings without explicit approval.
- Use official Arch packages for the Hyprland baseline. Avoid AUR rice bundles and `-git` Hyprland packages unless a verified requirement needs them.
- Run `./scripts/check.sh` and report exactly what was verified.
- Update `.ai/context.md` only with durable project status and decisions; never store secrets or conversations.

## Commits and pushing

- Commit freely, without asking. Small, coherent commits on a branch are the
  rollback path, and creating one is not a decision that needs approval.
- **Never push without explicit permission, every time.** Pushing is publishing.
  Approval for one push is not approval for the next.
