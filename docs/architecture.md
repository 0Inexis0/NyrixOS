# Architecture

## Shared source layers

- `system/`: Arch + Hyprland base manifest, Lua compositor defaults and session entry.
- `desktop/`: Waybar, Quickshell, Fish/Foot/Fastfetch, cursor and wallpaper; shared
  config, package manifest and namespaced helpers.
- `install/`: setup on an existing x86_64 Arch installation with a regular user.
  Preserves existing configuration by default; does not partition or create users.
- `iso/` and `scripts/`: Archiso releng overlay/profile generation and ISO build.
  Consume the same system/desktop layer; live media remains ephemeral.
- `tests/`: shortcut validation/rollback and Dynamic Island data tests.

## Session and UI

`nyrix-session` starts Hyprland; `nyrix-desktop` starts Waybar and Quickshell.
Waybar supplies workspace/title/status pills. Quickshell supplies the wallpaper,
Dynamic Island, detail menus, control center and floating Settings window.
NetworkManager, BlueZ and PipeWire provide live device state. Missing hardware is
explicitly unavailable. Fish is Foot's interactive shell, not a replacement for
shell scripts or the account's TTY login setup.

## User state and updates

German/English selection, shortcut overrides, weather location and account data
remain user-specific. Public defaults must not include private infrastructure or
credentials. The updater fetches upstream main, validates the installer payload,
backs up config and runs full Arch updates plus the shared setup in update mode.
This is not an atomic or rollback-capable OS update. The complete remote path
still needs testing after the installable sources are published.

## Artifacts and verification

The development VM is a persistent disk installation with separately verified
boot/persistence; browser console infrastructure is external to the OS and not
shipped. Historical minimal live images do not contain the current desktop.
A fresh ISO build/boot test and clean end-to-end public setup remain required.
See desktop/README.md for UI checks and minimal-verification.md for the older
minimal baseline. Rolling Arch mirrors are not a version-locked build input.

## Not yet delivered

A full graphical disk installer, Secure Boot/release signing, atomic rollback,
physical-hardware certification and a stable public release.
