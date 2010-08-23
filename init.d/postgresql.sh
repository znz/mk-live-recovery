#!/bin/sh
for initd in /etc/init.d/postgresql-*; do
	if [ -x "$initd" ]; then
		$SUDO_CMD "$initd" "$@"
	fi
done
