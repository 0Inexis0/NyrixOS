# NyrixOS working conventions

- Build a public Arch Linux / Hyprland distribution, not only personal dotfiles.
- The first milestone is a UEFI-bootable live ISO based on Archiso's `releng` profile.
- Once a bootable artifact exists, provision a dedicated test VM with browser-accessible console/desktop access for Tyler. Verify actual boot and desktop interaction; a successful ISO build alone is not completion.
- Keep the test environment separate from production services. Inspect existing infrastructure before provisioning or changing configuration.
- Do not commit credentials, private infrastructure details, generated ISOs, or disk images.
- Prefer established upstream build and installation tools over bespoke replacements.

## Owner decisions — 2026-11-18

- Keep the current baseline plain Arch Linux + Hyprland, with only required system components and a usable terminal. Do not add a bar, launcher, browser, file manager, theme or welcome application until requested.
- The owner wants a real, persistent disk installation in the test VM, not only an ephemeral live ISO. Verify boot with the ISO disconnected and persistence after reboot.
- When the owner requests a commit, commit and push to `main` using the owner's verified Git author/account. Never invent author details or co-author credit. Preserve remote changes; no unsolicited force-push.

## Desktop milestone — 2026-11-18

- Owner explicitly approved Waybar plus a custom Quickshell control center. This supersedes the earlier no-bar/no-theme baseline for the desktop layer only.
- Keep Arch + Hyprland base separate from desktop packages/configuration. Waybar is the bar; Quickshell provides panels, not a competing bar.
- First prototype: slim floating top bar, top-right control center; no unrelated app suite.
- Keep Git changes local until owner connects their verified Git identity.

- Status icons open separate compact menus below the bar: Wi-Fi switch/list, Bluetooth switch/devices, volume slider. Only the chevron or existing shortcut opens the full control center. Keep borderless dark-grey pills and distro icon.

- Foot uses Fish as its default interactive shell, with the NyrixOS Fastfetch greeting. Preserve the login shell / TTY desktop startup. Keep terminal configs and packages in the shared desktop layer for script and ISO installs.

- Support German and English across the NyrixOS desktop and user locale. Settings categories: Network & Bluetooth, Display, Personalization, Updates. Updates fetch the published main repository and perform full Arch updates, showing changelog and errors. Never claim unpublished local work is remotely available.
- Settings includes a bilingual, editable Shortcuts cheat sheet. Keep user shortcut overrides separate from shipped defaults and preserve them during updates. Validate conflicts and reload failures before reporting a saved binding.
- Center Dynamic Island must expand/collapse as one smooth persistent pill, not a separate fading popup. Keep it compact; categories share one slim capsule with vertical separators. Never fabricate AI quotas, GPU/sensor readings or calendar events. User weather location and account data must remain outside public defaults.
