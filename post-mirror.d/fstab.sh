#!/bin/bash
set -eux

generate_fstab () {
    ROOT_DEVICE=$1
    SWAP_DEVICE=$2
    ROOT_UUID=$($SUDO_CMD blkid -o value -s UUID "$ROOT_DEVICE")
    if [ -n "$ROOT_UUID" ]; then
        ROOT_FS="UUID=${ROOT_UUID}"
    else
        ROOT_FS="$ROOT_DEVICE"
    fi
    SWAP_UUID=$($SUDO_CMD blkid -o value -s UUID "$SWAP_DEVICE")
    if [ -n "$SWAP_UUID" ]; then
        SWAP_FS="UUID=${SWAP_UUID}"
    else
        SWAP_FS="$SWAP_DEVICE"
    fi
    cat <<EOF
# /etc/fstab: static file system information.
#
# Use 'blkid -o value -s UUID' to print the universally unique identifier
# for a device; this may be used with UUID= as a more robust way to name
# devices that works even if disks are added and removed. See fstab(5).
#
# <file system> <mount point>   <type>  <options>       <dump>  <pass>
proc            /proc           proc    nodev,noexec,nosuid 0       0
# / was on /dev/sda1 during installation
$ROOT_FS /               ext4    errors=remount-ro 0       1
# swap was on /dev/sda5 during installation
$SWAP_FS none            swap    sw              0       0
EOF
}

make_etc_fstab () {
    ${SUDO_CMD-} mv "$MOUNTPOINT/etc/fstab" "$MOUNTPOINT/etc/fstab.bak"
    generate_fstab "$ROOT_DEVICE" "$SWAP_DEVICE" | ${SUDO_CMD-} tee "$MOUNTPOINT/etc/fstab"
}

make_etc_fstab
