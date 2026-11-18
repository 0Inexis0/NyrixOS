#!/usr/bin/env bash
set -euo pipefail
repo=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
if (( EUID != 0 )); then
    echo 'Run with sudo on a dedicated Arch Linux build host.' >&2
    exit 1
fi
for tool in mkarchiso pacman python3; do
    command -v "$tool" >/dev/null || { echo "Missing build dependency: $tool" >&2; exit 1; }
done
build_root=${NYRIX_BUILD_ROOT:-$repo/build}
output=${NYRIX_OUTPUT_DIR:-$repo/out}
mkdir -p "$build_root" "$output"
run=$(mktemp -d "$build_root/run.XXXXXXXX")
python3 "$repo/scripts/prepare-profile.py" "$run/profile"
pacman -Q archiso > "$run/build-tools.txt"
cp "$run/profile/packages.x86_64" "$run/requested-packages.txt"
# Fail before building if an official package was renamed or removed.
mapfile -t packages < <(sed '/^[[:space:]]*#/d; /^[[:space:]]*$/d' "$run/profile/packages.x86_64")
pacman -Si "${packages[@]}" > "$run/package-info.txt"
mkarchiso -v -w "$run/work" -o "$output" "$run/profile" 2>&1 | tee "$run/build.log"
(cd "$output" && sha256sum -- *.iso > SHA256SUMS)
printf 'Build evidence: %s\nISO output: %s\n' "$run" "$output"
