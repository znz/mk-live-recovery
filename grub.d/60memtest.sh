#!/bin/sh
if [ -f "${CD_ROOT}/boot/memtest86+.bin" ]; then
    cat <<EOF
menuentry "memtest86+でメモリをテストする (Memory test)" {
	linux16	/boot/memtest86+.bin
}
EOF
fi
