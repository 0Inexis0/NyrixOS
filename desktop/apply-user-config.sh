#!/usr/bin/env bash
# Run as the destination user, never as root. No overwrites by default.
set -euo pipefail
[[ $EUID != 0 ]] || { echo 'Run as the desktop user, not root.' >&2; exit 1; }
repo=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
config=${XDG_CONFIG_HOME:-$HOME/.config}
copy_new() {
    local source=$1 target=$2
    if [[ ${NYRIX_UPDATE:-0} == 1 ]]; then
        # Backup is created by the root installer before this explicit update mode.
        [[ ! -L $target ]] || { echo "Refusing config symlink: $target" >&2; exit 1; }
        mkdir -p "$(dirname -- "$target")"
        cp -- "$source" "$target"
    elif [[ -e $target || -L $target ]]; then
        echo "Preserved: $target"
    else
        mkdir -p "$(dirname -- "$target")"
        (set -o noclobber; cat "$source" > "$target")
        chmod 644 "$target"
    fi
}
while IFS= read -r -d '' source; do
    copy_new "$source" "$config/${source#"$repo/desktop/config/"}"
done < <(find "$repo/desktop/config" -type f -print0)
# Existing legacy Hyprland config must also be respected.
if [[ ! -e $config/hypr/hyprland.conf && ! -L $config/hypr/hyprland.conf ]]; then
    copy_new "$repo/system/config/hyprland.lua" "$config/hypr/hyprland.lua"
fi
echo 'Existing Hyprland users: add nyrix-desktop to startup and bind nyrix-controls.'
