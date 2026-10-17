#!/usr/bin/env bash
set -euo pipefail

repo_dir="$(cd "$(dirname "$0")/.." && pwd)"
output_dir="${1:-$repo_dir/inventory/current}"

mkdir -p "$output_dir"

write_list() {
  local output_file="$1"
  shift
  "$@" | LC_ALL=C sort -u >"$output_dir/$output_file"
}

if command -v pacman >/dev/null 2>&1; then
  write_list arch-explicit-packages.txt pacman -Qqen
  write_list arch-foreign-packages.txt pacman -Qqem
fi

if command -v dnf >/dev/null 2>&1; then
  write_list fedora-user-packages.txt dnf repoquery --userinstalled --qf '%{name}'
fi

if command -v flatpak >/dev/null 2>&1; then
  write_list flatpak-apps.txt flatpak list --app --columns=application
fi

if command -v systemctl >/dev/null 2>&1; then
  rm -f "$output_dir/enabled-system-units.txt" "$output_dir/enabled-user-units.txt"
  if units="$(systemctl list-unit-files --state=enabled --no-legend --no-pager 2>/dev/null)"; then
    awk '{print $1}' <<<"$units" | LC_ALL=C sort -u >"$output_dir/enabled-system-units.txt"
  else
    printf 'Warning: system service inventory was unavailable.\n' >&2
  fi
  if units="$(systemctl --user list-unit-files --state=enabled --no-legend --no-pager 2>/dev/null)"; then
    awk '{print $1}' <<<"$units" | LC_ALL=C sort -u >"$output_dir/enabled-user-units.txt"
  else
    printf 'Warning: user service inventory was unavailable.\n' >&2
  fi
fi

printf 'Inventory written to %s\n' "$output_dir"
printf 'Review it before committing; this script intentionally omits credentials and file contents.\n'
