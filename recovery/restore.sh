#!/bin/bash
set -e

export LIVE_RECOVERY_MODE="${LIVE_RECOVERY_MODE:-true}"
export SFDISK_D=${SFDISK_D:-/cdrom/recovery/sfdisk-d.txt}
export TARGET_DRIVE=${TARGET_DRIVE:-/dev/sda}
export MOUNTPOINT=${MOUNTPOINT:-/target}
export SRC_DIR=${SRC_DIR:-/rofs}
export WORKDIR=$(mktemp -d /tmp/restore.XXXXXXXXXX)

umount $MOUNTPOINT || :
if [ -f ./format-and-mirror-copy ]; then
    exec ./format-and-mirror-copy live
else
    exec /usr/sbin/format-and-mirror-copy live
fi
