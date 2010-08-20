#!/bin/bash
set -e

cd $(dirname $0)

export SFDISK_D=${SFDISK_D:-$(pwd)/sfdisk-d.txt}
export TARGET_DRIVE=${TARGET_DRIVE:-/dev/sdb}
export MOUNTPOINT=${MOUNTPOINT:-/target}
export SRC_DIR=${SRC_DIR:-/rofs}

/usr/sbin/format-and-mirror-copy live
