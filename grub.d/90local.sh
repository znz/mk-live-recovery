#!/bin/sh
cat <<EOF
menuentry "最初のHDDから起動 (Boot from first hard disk)" {
	set root=(hd0)
	chainloader +1
}
menuentry "2番目のHDDから起動 (Boot from second hard disk)" {
	set root=(hd1)
	chainloader +1
}
menuentry "再起動 (reboot)" {
	reboot
}
menuentry "停止 (halt)" {
	halt
}
EOF
