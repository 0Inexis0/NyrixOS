#!/usr/bin/env bash
# Add the minimal NyrixOS baseline to an installed Arch system (or arch-chroot).
# Never partition disks, create users, change passwords or enable automatic login.
set -euo pipefail
repo=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
usage() { echo 'Usage: sudo bash install/install.sh --user EXISTING_USER [--dry-run]'; }
user=''
dry_run=0
while (($#)); do
    case "$1" in
        --user) [[ $# -ge 2 ]] || { usage >&2; exit 2; }; user=$2; shift 2 ;;
        --dry-run) dry_run=1; shift ;;
        -h|--help) usage; exit 0 ;;
        *) usage >&2; exit 2 ;;
    esac
done
[[ $EUID == 0 ]] || { echo 'Run as root or with sudo.' >&2; exit 1; }
[[ -e /etc/arch-release && $(uname -m) == x86_64 ]] || { echo 'Requires installed x86_64 Arch Linux.' >&2; exit 1; }
# Refuse a live overlay; install inside arch-chroot or boot the installed OS first.
[[ ! -d /run/archiso ]] || { echo 'This is the live system. See install/README.md for disk installation.' >&2; exit 1; }
[[ $user =~ ^[a-z_][a-z0-9_-]*\$?$ && $user != root ]] || { echo 'Specify an existing non-root user.' >&2; exit 2; }
entry=$(getent passwd "$user") || { echo 'User does not exist.' >&2; exit 1; }
IFS=: read -r _ _ uid gid _ user_home _ <<< "$entry"
[[ $uid -ge 1000 && $user_home == /* && $user_home != / && -d $user_home ]] || { echo 'Expected a regular user with an existing home directory.' >&2; exit 1; }
mapfile -t packages < <(sed '/^[[:space:]]*#/d; /^[[:space:]]*$/d' "$repo/system/packages.x86_64" "$repo/desktop/packages.x86_64")
((${#packages[@]})) || exit 1
printf 'Install/update the baseline for %s: %s\n' "$user" "${packages[*]}"
echo 'Existing desktop packages, user configuration, login and network settings will be preserved.'
if ((dry_run)); then exit 0; fi
# Full upgrade, not a partial Arch upgrade. pacman retains its confirmation prompt.
pacman -Syu --needed "${packages[@]}"
# Both supported locales; retain all other enabled locales.
for locale in de_DE.UTF-8 en_US.UTF-8; do
    grep -qx "$locale UTF-8" /etc/locale.gen || printf '%s UTF-8\n' "$locale" >> /etc/locale.gen
done
locale-gen
backup=/var/lib/nyrixos/backups/$(date -u +%Y%m%dT%H%M%S)-$$
if [[ ${NYRIX_UPDATE:-0} == 1 ]]; then
    install -d -m700 "$backup"
    cp -a "$user_home/.config" "$backup/user-config"
    cp -a /usr/local/bin "$backup/local-bin"
    install -m755 "$repo/system/nyrix-session" /usr/local/bin/nyrix-session
    for source in "$repo"/desktop/bin/*; do install -m755 "$source" /usr/local/bin/; done
fi
# BlueZ starts on hardware-equipped systems; preserve existing service overrides.
systemctl enable bluetooth.service
# Namespaced launcher; never modify user shell profiles or graphical login settings.
if [[ -e /usr/local/bin/nyrix-session || -L /usr/local/bin/nyrix-session ]]; then
    cmp -s "$repo/system/nyrix-session" /usr/local/bin/nyrix-session || {
        echo '/usr/local/bin/nyrix-session already differs; refusing to overwrite.' >&2; exit 1;
    }
else
    install -Dm755 "$repo/system/nyrix-session" /usr/local/bin/nyrix-session
fi
# Stage only public config outside /root so runuser can read it safely.
stage=$(mktemp -d /tmp/nyrix-setup.XXXXXXXX)
trap 'rm -rf -- "$stage"' EXIT
chmod 755 "$stage"
cp -R "$repo/system" "$repo/desktop" "$stage/"
find "$stage" -type d -exec chmod 755 {} +
find "$stage" -type f -exec chmod 644 {} +
for source in "$repo"/desktop/bin/*; do
    target=/usr/local/bin/$(basename "$source")
    if [[ -e $target || -L $target ]]; then
        cmp -s "$source" "$target" || { echo "Preserving conflicting launcher: $target; resolve manually." >&2; exit 1; }
    else
        install -m755 "$source" "$target"
    fi
done
runuser -u "$user" -- env HOME="$user_home" XDG_CONFIG_HOME="$user_home/.config" NYRIX_UPDATE="${NYRIX_UPDATE:-0}" bash "$stage/desktop/apply-user-config.sh"
printf '\nReady. Log in locally as %s, then run: nyrix-session\n' "$user"
echo 'No autologin, passwordless sudo, remote access or unrelated desktop apps were added.'
echo 'NetworkManager is installed but your existing network setup is unchanged.'
