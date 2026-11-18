# NyrixOS development live ISO

Arch Linux + Hyprland with Foot, Waybar and a Quickshell control center.
No app launcher, browser, file manager or welcome application.

## Build

Use a dedicated **x86_64 Arch Linux VM**, approximately 3–4 GiB RAM and 30 GiB
free disk space. Archiso requires root for mounts/chroot.

```sh
sudo pacman -Syu --needed archiso python
sudo ./scripts/build-iso.sh
```

The script copies the packaged Archiso `releng` profile, applies `iso/overlay`,
checks requested packages and writes the ISO and SHA256SUMS to `out/`.
Intermediate profiles and logs remain under `build/run.*`. Override
`NYRIX_BUILD_ROOT` or `NYRIX_OUTPUT_DIR` for a separate build disk.

## Use

- x86_64 UEFI, Secure Boot disabled; 2 vCPUs, 3 GiB RAM and virtio graphics suffice
  for the development VM.
- Local `nyrix` auto-login starts Hyprland, Foot, Waybar and Quickshell.
- German keyboard; Super+Enter or Ctrl+Alt+Enter opens a terminal.
- Use `nmtui` for networking. The Quickshell Settings window also exposes network controls; no app launcher is bundled.
- Root is locked and SSH is disabled; no private credentials are included.
- The ISO itself is still live/ephemeral. A full installation requires a system
  disk; persistence is not achieved by merely attaching an ISO to a VM.

`system/packages.x86_64` defines the base; `desktop/packages.x86_64` adds the shell; the ISO also needs
Archiso/live-media and disk-preparation tools. Browser console access is supplied
by the VM host, not embedded into the distribution.

See [architecture](../docs/architecture.md) and [verification](../docs/minimal-verification.md).

This source has moved beyond the last boot-tested minimal ISO. A new build and
boot test are required before publishing the desktop ISO. Archinstall and a copy
of the public setup sources are bundled under `/opt/nyrixos`; they are not an
automatically executed or fully validated NyrixOS disk installer.
