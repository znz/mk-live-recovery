#!/bin/bash
set -eux

$SUDO_CMD chroot "$MOUNTPOINT" grub-install "$TARGET_DRIVE"
$SUDO_CMD chroot "$MOUNTPOINT" update-grub
