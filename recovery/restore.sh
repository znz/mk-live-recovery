#!/bin/bash
set -ex
. ssft.sh
SSFT_FRONTEND=${SSFT_FRONTEND:-$(ssft_choose_frontend)}
export SSFT_FRONTEND
cd "$(dirname "$0")"
TIT="$(basename "$0")"

DISK=${DISK:-/dev/sda}

MSG="$DISK をフォーマットします。よろしいですか? (Format $DISK, OK?)"
if ssft_yesno "$TIT" "$MSG"; then
    :
else
    exit $?
fi
MSG="$DISK をフォーマットします。問題があればこのまま続行せずにシャットダウンしてください。 (Format $DISK, or shutdown now.)"
if ssft_display_message "$TIT" "$MSG"; then
    :
else
    exit $?
fi
echo "パーティション設定中..."
swapoff -a
if [ -n "$(LANG=C sudo sfdisk -R /dev/sda 2>&1 | grep BLKRRPART)" ]; then
    MSG="$DISK が使用中です。フォーマットできません。($DISK is currently in use. Can not format.)"
    ssft_display_error "$TIT" "$MSG"
    exit 1
fi
sfdisk --force /dev/sda < sfdisk-d-sda.txt
echo "スワップ領域初期化中 (formatting swap)..."
mkswap -L sda-swap /dev/sda5
echo "ルートパーティション初期化中 (formatting root partition)..."
mkfs.ext4 -L sda-root /dev/sda1
echo "ルートパーティションマウント中(mounting root partition)..."
mkdir -p /target
mount /dev/sda1 /target
echo "ルートパーティションにコピー中(copying to root partition)..."
rsync -aAHX --progress /rofs/ /target/
echo "ブートローダ設定中(setup boot loader)..."
mount --bind /dev /target/dev
mount -t proc proc /target/proc
chroot /target grub-install /dev/sda
echo "ルートパーティションアンマウント中(unmounting root partition)..."
umount /target/proc
umount /target/dev
umount /target
echo "終了。(done)"
MSG="リカバリが終了しました。再起動してください。(Recovery finished. Please reboot."
if ssft_display_message "$TIT" "$MSG"; then
    :
else
    exit $?
fi
