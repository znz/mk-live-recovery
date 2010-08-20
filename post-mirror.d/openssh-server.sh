#!/bin/bash
set -eu

if [ -f /etc/default/mk-live-recovery ]; then
    . /etc/default/mk-live-recovery
fi

generate_openssh_host_keys () {
    $SUDO_CMD touch "$MOUNTPOINT/etc/ssh/sshd_not_to_be_run"
    $SUDO_CMD chroot "$MOUNTPOINT" dpkg-reconfigure -plow openssh-server
    $SUDO_CMD rm -f "$MOUNTPOINT/etc/ssh/sshd_not_to_be_run"
}

case "$1" in
    full|live)
	set -x
	generate_openssh_host_keys
	;;
esac
