#!/bin/bash
set -ex
. ssft.sh
SSFT_FRONTEND=${SSFT_FRONTEND:-$(ssft_choose_frontend)}
export SSFT_FRONTEND
cd "$(dirname "$0")"
TIT="$(basename "$0")"

TEXTDOMAIN=restore
export TEXTDOMAIN
if [ -d locale ]; then
  TEXTDOMAINDIR=$(pwd)/locale
  export TEXTDOMAINDIR
fi

DISK=${DISK:-/dev/sda}

MSG="$(eval_gettext 'Format $DISK, OK?')"
if ssft_yesno "$TIT" "$MSG"; then
    :
else
    exit $?
fi
MSG="$(eval_gettext 'Format $DISK, or shutdown now.')"
if ssft_display_message "$TIT" "$MSG"; then
    :
else
    exit $?
fi
gettext "Partitioning..."; echo
swapoff -a
if [ -n "$(LANG=C sudo sfdisk -R "$DISK" 2>&1 | grep BLKRRPART)" ]; then
    MSG="$(eval_gettext '$DISK is currently in use. Can not format.')"
    ssft_display_error "$TIT" "$MSG"
    exit 1
fi
sfdisk --force "$DISK" < sfdisk-d-sda.txt
eval_gettext 'Formatting ${DISK}5 as swap...'; echo
mkswap -L sda-swap /dev/sda5
eval_gettext 'Formatting ${DISK}1 as root partition...'; echo
mkfs.ext4 -L sda-root /dev/sda1
eval_gettext 'Mounting ${DISK}1 to /target...'; echo
mkdir -p /target
mount /dev/sda1 /target
gettext 'Copying files to target partition...'
rsync -aAHX --progress /rofs/ /target/
gettext 'Setup boot loader...'
mount --bind /dev /target/dev
mount -t proc proc /target/proc
chroot /target grub-install /dev/sda
gettext 'Setup openssh-server...'
touch /target/etc/ssh/sshd_not_to_be_run
chroot /target dpkg-reconfigure -plow openssh-server
rm -f /target/etc/ssh/sshd_not_to_be_run
gettext 'Unmounting target partition...'; echo
umount /target/proc
umount /target/dev
umount /target
gettext 'done.'

# Notify the user that a reboot is required
if [ -x /usr/share/update-notifier/notify-reboot-required ]; then
    /usr/share/update-notifier/notify-reboot-required
fi
MSG="$(gettext 'Recovery finished. Please reboot.')"
if ssft_display_message "$TIT" "$MSG"; then
    :
else
    exit $?
fi
