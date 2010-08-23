#!/bin/sh
for initd in /etc/init.d/apache*; do
	if [ -x "$initd" ]; then
		$SUDO_CMD "$initd" "$@"
	fi
done
