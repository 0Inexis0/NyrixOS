<div align="center">

<img src="assets/nyrix-logo.svg" width="96" alt="NyrixOS logo">

# NyrixOS

**A preconfigured Hyprland desktop built on Arch Linux.**

[![Stars](https://img.shields.io/github/stars/0Inexis0/NyrixOS?style=flat-square&label=Stars&labelColor=212544&color=a7ede1)](https://github.com/0Inexis0/NyrixOS/stargazers)
[![Commits](https://img.shields.io/github/commit-activity/t/0Inexis0/NyrixOS/main?style=flat-square&label=Commits&labelColor=212544&color=ada3fa)](https://github.com/0Inexis0/NyrixOS/commits/main/)
[![Last commit](https://img.shields.io/github/last-commit/0Inexis0/NyrixOS/main?style=flat-square&label=Last%20commit&labelColor=212544&color=a7ede1)](https://github.com/0Inexis0/NyrixOS/commits/main/)

[**Live ISO**](iso/) · [Install script](install/) · [Releases](https://github.com/0Inexis0/NyrixOS/releases)

</div>

## Project status

NyrixOS is an early-development **Arch Linux + Hyprland** distribution with a
Waybar / Quickshell desktop. No browser, file manager or large app suite is bundled.

### Current desktop

- Borderless dark-grey bar pills, distro icon, three default workspaces and the
  focused-window title in one pill.
- Compact animated **Dynamic Island**: Dashboard calendar, Performance metrics,
  AI usage windows and current weather / five-day forecast. Tabs share one capsule.
- Separate Wi-Fi, Bluetooth and volume menus; compact control center with radio
  switches, brightness and volume sliders, and Settings.
- Settings window with profile/sidebar: Network & Bluetooth, Display,
  Personalization, Shortcuts and Updates. German and English UI.
- Editable shortcut cheat sheet; Git changelog and explicit repository + Arch
  updates, with configuration backups.
- Foot with Fish and a custom Fastfetch greeting, rounded/translucent terminal,
  Breeze Light cursor and the supplied landscape wallpaper.

AI limits need separately connected accounts; Codex limits are not universal
ChatGPT limits. Missing hardware/sensors are shown as unavailable, not zero.
Weather location and account data are not shipped as public defaults.

### Install and build

- [Set up an existing Arch installation](install/) — not a disk partitioner.
- [Build the development live ISO](iso/) — Archiso on an Arch build host.
- [Desktop details and verification history](desktop/)
- [Architecture](docs/architecture.md) · [Changelog](CHANGELOG.md)
- [Base packages](system/packages.x86_64) · [Desktop packages](desktop/packages.x86_64)

The installed development VM runs this desktop. The last boot-tested minimal ISO
predates it: **the current desktop ISO has not been rebuilt or boot-tested**.
There is no published stable release. A clean setup run, current ISO boot test,
physical-hardware checks and authenticated AI-limit checks remain open.
The full repository-update path requires the installable sources to be published.

### Development checks

```sh
python3 -m unittest discover -s tests -v
```

These tests cover shortcut validation/rollback and island data handling. They do
not replace compositor, hardware, installer or ISO boot tests.
