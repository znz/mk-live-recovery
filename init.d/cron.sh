#!/bin/bash
for init_conf in /etc/init/{atd,cron}.conf; do
	if [ -f "$init_conf" ]; then
		init_conf="${init_conf##*/}"
		$SUDO_CMD initctl "$@" "${init_conf%.conf}" || :
	fi
done
