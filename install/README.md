# Set up NyrixOS on existing Arch Linux

Requires a working x86_64 Arch installation, internet, sudo/root, and an existing
regular desktop user. Review the scripts before running. Start with a fresh Arch
installation if you want only the NyrixOS package selection: existing apps are
never removed.

```sh
git clone https://github.com/0Inexis0/NyrixOS.git
cd NyrixOS
sudo bash install/install.sh --user "$USER" --dry-run
sudo bash install/install.sh --user "$USER"
```

The setup performs a full `pacman -Syu` with confirmation, installs the base and
desktop package lists, adds namespaced launchers and copies missing user configs.
Existing configs and launchers are preserved; conflicting launchers stop setup.
No passwords, user accounts, disk partitions, bootloader, networking policies,
autologin or passwordless sudo are created or changed.

Log in on a local console and run `nyrix-session`. Existing Hyprland users should
merge the startup command `nyrix-desktop` and bind `nyrix-controls` into their own
configuration. Default shortcuts: Super+Enter terminal, Super+C control center.

This is an early setup script, NOT a complete disk installer. For a fresh machine,
install Arch using its official installation guide or `archinstall` first, then
run this setup. Choose a minimal Arch profile to avoid unrelated desktop packages.
See https://wiki.archlinux.org/title/Installation_guide and
https://wiki.archlinux.org/title/Archinstall .

The script's syntax/config-preservation behavior is checked; a clean end-to-end
public setup run and a new desktop ISO boot test are still release prerequisites.
