#!/bin/sh
if [ "${LOCAL_TEST:+set}" != set ]; then
	exit
fi

LIVE_OPTIONS="boot=casper nopersistent rw break=local"
if [ -n "$SUDO_USER" ]; then
	LIVE_OPTIONS="$LIVE_OPTIONS username=$SUDO_USER"
else
	LIVE_OPTIONS="$LIVE_OPTIONS username=$(id -un)"
fi
cat <<EOF
menuentry "テストモードでライブ環境を起動する (Start Live GNU/Linux in Graphical Mode)" {
	linux	/boot/vmlinuz $LIVE_OPTIONS
	initrd	/boot/initrd.img
}
EOF
