#!/bin/bash
set -eu

if [ -f /etc/default/mk-live-recovery ]; then
    . /etc/default/mk-live-recovery
fi

install_grub () {
    $SUDO_CMD chroot "$MOUNTPOINT" grub-install "$TARGET_DRIVE"
    $SUDO_CMD chroot "$MOUNTPOINT" update-grub
}

case "$1" in
    full|live)
	set -x
	install_grub
	;;
esac
