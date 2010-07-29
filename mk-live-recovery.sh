#!/bin/bash
# http://www.geekconnection.org/remastersys/info.html
#set -e
set -x

WORKDIR=${WORKDIR:-"/home/_work"}
CD_ROOT=${CD_ROOT:-"/home/_cd"}
OUT_ISO=${OUT_ISO:-$WORKDIR/live-recovery-$(date '+%Y%m%d').iso}
KERNEL_RELEASE=${KERNEL_RELEASE:-"$(uname -r)"}
INITRD_IMG=${INITRD_IMG:-"/boot/initrd.img-$KERNEL_RELEASE"}
VMLINUZ=${VMLINUZ:-"/boot/vmlinuz-$KERNEL_RELEASE"}
if [ -z "$SUDO_CMD" ] && [ `id -u` -eq 0 ]; then
    SUDO_CMD=
else
    SUDO_CMD=${SUDO_CMD:-"sudo"}
fi
ROOT_FS="${WORKDIR}/rootfs"
FORMAT=squashfs
FS_DIR=casper
EXCLUDE_FILE=${EXCLUDE_FILE:-"$WORKDIR/exclude-list.txt"}

clean () {
    $SUDO_CMD rm -rf "${WORKDIR}"
    $SUDO_CMD rm -rf "${CD_ROOT}"
}

prepare_dir () {
    $SUDO_CMD mkdir -p "${ROOT_FS}"
    $SUDO_CMD mkdir -p "${CD_ROOT}"
}

prepare_exclude () {
    local f
    {
	for f in exclude.d/*.sh; do
	    . $f
	done
    } | $SUDO_CMD tee "$EXCLUDE_FILE"
}

build_root_fs () {
    $SUDO_CMD rsync -av --delete -HAX --one-file-system --exclude-from="$EXCLUDE_FILE" "/" "${ROOT_FS}/"

    cp -rp root-fs.d "${ROOT_FS}/tmp/"
    $SUDO_CMD mount -o bind /dev/ "${ROOT_FS}/dev"
    $SUDO_CMD mount -t proc proc "${ROOT_FS}/proc"
    trap umount_in_root_fs 0
    $SUDO_CMD chroot "${ROOT_FS}" /bin/bash -ex <<'EOF'
export LANG=C
for f in /tmp/root-fs.d/*.sh; do
    . $f
done
EOF
    umount_in_root_fs
    trap "" 0
}

umount_in_root_fs () {
    $SUDO_CMD umount "${ROOT_FS}/dev" || :
    $SUDO_CMD umount "${ROOT_FS}/proc" || :
}

pack_root_fs () {
    $SUDO_CMD mkdir -p "${CD_ROOT}/${FS_DIR}"
    $SUDO_CMD rm -f "${CD_ROOT}/${FS_DIR}/filesystem.${FORMAT}"
    $SUDO_CMD mksquashfs "${ROOT_FS}" "${CD_ROOT}/${FS_DIR}/filesystem.${FORMAT}"
}

build_cd_boot () {
    $SUDO_CMD mkdir -p "${CD_ROOT}"/boot/grub/locale
    $SUDO_CMD cp -vp /usr/share/grub/unicode.pf2 "${CD_ROOT}/boot/grub/"
    if [ -f grub2-ja.po ]; then
	if [ ! -e grub2-ja.mo ] || [ grub2-ja.mo -ot grub2-ja.po ]; then
	    msgfmt -o grub2-ja.mo grub2-ja.po
	fi
	$SUDO_CMD cp -vp grub2-ja.mo "$CD_ROOT/boot/grub/locale/ja.mo"
    elif [ -f /boot/grub/locale/ja.mo ]; then
	$SUDO_CMD cp -vp /boot/grub/locale/ja.mo "${CD_ROOT}/boot/grub/locale/ja.mo"
    fi
    $SUDO_CMD cp -vp "${ROOT_FS}/boot/vmlinuz-$(uname -r)" "${CD_ROOT}/boot/vmlinuz"
    $SUDO_CMD cp -vp "${ROOT_FS}/boot/initrd.img-$(uname -r)" "${CD_ROOT}/boot/initrd.img"
    $SUDO_CMD cp -vp "${ROOT_FS}/boot/memtest86+.bin" "${CD_ROOT}/boot"

}

make_grub_cfg () {
    {
	for f in grub.d/*.sh; do
	    . $f
	done
    } | $SUDO_CMD tee "${CD_ROOT}/boot/grub/grub.cfg"
}

make_recovery_sh () {
    $SUDO_CMD mkdir -p "${CD_ROOT}/recovery"
    $SUDO_CMD sfdisk -d /dev/sda | $SUDO_CMD tee "${CD_ROOT}/recovery/sfdisk-d-sda.txt"
    $SUDO_CMD tee "${CD_ROOT}/recovery/restore.sh" <<'EOF'
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
EOF
    $SUDO_CMD chmod +x "${CD_ROOT}/recovery/restore.sh"
}

build_iso () {
    (
	cd ${CD_ROOT} &&
	find . -name md5sum.txt -prune -o -type f -print0 |
	xargs -0 sudo md5sum |
	$SUDO_CMD tee "${CD_ROOT}/md5sum.txt"
    )
    $SUDO_CMD grub-mkrescue "--output=${OUT_ISO}" "${CD_ROOT}"
}

if [ -n "$1" ]; then
    "$@"
else
    prepare_dir
    prepare_exclude
    build_root_fs
    pack_root_fs
    build_cd_boot
    make_grub_cfg
    make_recovery_sh
    build_iso
fi
