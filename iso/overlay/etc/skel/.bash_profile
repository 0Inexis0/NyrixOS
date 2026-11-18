# Start the plain desktop on the local first console, not remote shells.
if [[ -z ${WAYLAND_DISPLAY:-} && -z ${DISPLAY:-} && $(tty) == /dev/tty1 ]]; then
    exec /usr/local/bin/nyrix-session
fi
