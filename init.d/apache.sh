#!/bin/sh
for initd in /etc/init.d/apache*; do
	if [ -x "$initd" ]; then
		"$initd" "$@"
	fi
done
