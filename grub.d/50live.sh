#!/bin/sh
LIVE_OPTIONS="boot=casper nopersistent rw quiet splash"
LIVE_OPTIONS="$LIVE_OPTIONS username=${SUDO_USER:-$(id -un)} hostname=recovery-$(hostname -s)"

cat <<EOF
menuentry "グラフィカルモードでライブ環境を起動する (Start Live GNU/Linux in Graphical Mode)" {
	linux	/boot/vmlinuz $LIVE_OPTIONS
	initrd	/boot/initrd.img
}
menuentry "セーフグラフィカルモードでライブ環境を起動する (Start Live GNU/Linux in Safe Graphical Mode)" {
	linux	/boot/vmlinuz $LIVE_OPTIONS xforcevesa
	initrd	/boot/initrd.img
}
menuentry "ディスクの破損をチェックする (Check disc for defects)" {
	linux	/boot/vmlinuz boot=casper integrity-check quiet splash
	initrd	/boot/initrd.img
}
EOF
