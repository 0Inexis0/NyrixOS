# Changelog

## Unreleased — development snapshot, 2026-11-18

### Foundation and delivery

- Arch + Hyprland base, separate desktop package/config layer.
- Archiso profile generator and build script; setup script for existing Arch.
- Persistent development installation verified separately from live media.

### Desktop

- Dark-grey, borderless Waybar pills with distro icon, grouped workspaces/window
  title and icon-only status. Three persistent workspaces by default.
- Wi-Fi/Bluetooth detail menus and muteable volume slider; compact control center.
- Profile/sidebar Settings window with network, display, personalization,
  editable shortcuts and updates; German/English support.
- Dynamic Island with compact expand/collapse animation and one segmented tab
  capsule: Dashboard | Performance | AI | Weather.
- Calendar, system metrics, optional account quota integrations, location search
  and Open-Meteo current weather / five-day forecast.
- Wallpaper, white Breeze Light cursor, Fish/Fastfetch and rounded translucent Foot.

### Updates and user data

- Explicit main-repository and full Arch package update path, Git changelog,
  config backups, error reporting and separate user shortcut overrides.
- Public defaults contain no personal weather location or account credentials.

### Known limitations

- Latest desktop ISO not rebuilt; clean public setup and complete remote-update
  cycle still require end-to-end validation and published sources.
- Physical Wi-Fi/Bluetooth/backlight and authenticated AI quotas unverified.
- Bluetooth first pairing uses an interactive terminal agent.
- No complete graphical disk installer, atomic rollback or stable release yet.

See desktop/README.md and docs/ for the detailed historical test record.
