#!/bin/sh
# D-Bus activation entrypoint for org.freedesktop.secrets on QNX.
# QNX desktop auto-logs in with no PAM, so nothing unlocks the GNOME login keyring the way a
# normal login would. This wrapper is what the org.freedesktop.secrets D-Bus service launches:
# it runs gnome-keyring-daemon in the foreground (so dbus tracks it and the bus name appears)
# and unlocks the login keyring using a per-device master password kept in a 0600 file.
#
# On a fresh system (no master file and no keyring yet) a random, per-device master password is
# generated automatically, so password autofill works out of the box with no image-side setup.
# The password is unique per device and is never shipped in the package. Like any auto-login /
# no-prompt setup, the key necessarily rests on disk (readable by this user/root); hardware-backed
# protection (TPM / secure element) would be a separate effort.
export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/var/run/$(id -u)}"
HOME="${HOME:-/var/home/qnx}"
MASTER="$HOME/.config/keyring/master"
KR="$HOME/.local/share/keyrings/login.keyring"

# Fresh system only: auto-provision a random per-device master. Guarded on "no keyring yet" so we
# never orphan an already-encrypted keyring by generating a key that cannot decrypt it.
if [ ! -e "$MASTER" ] && [ ! -e "$KR" ]; then
    mkdir -p "$(dirname "$MASTER")"
    ( umask 077; head -c 32 /dev/urandom | base64 | tr -d "\n" > "$MASTER" )
fi

if [ -r "$MASTER" ]; then
    # Create the login keyring on first use, then unlock it.
    if [ ! -f "$KR" ]; then
        cat "$MASTER" | gnome-keyring-daemon --daemonize --login --components=secrets,pkcs11 >/dev/null 2>&1
        slay -f gnome-keyring-daemon >/dev/null 2>&1
        sleep 1
    fi
    cat "$MASTER" | exec gnome-keyring-daemon --unlock --foreground --components=secrets,pkcs11
else
    # No master available (and a keyring already exists): behave like stock gnome-keyring.
    exec gnome-keyring-daemon --start --foreground --components=secrets
fi
