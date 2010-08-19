#!/bin/bash
for init_conf in /etc/init/ssh.conf; do
	if [ -f "$init_conf" ]; then
		init_conf="${init_conf##*/}"
		echo initctl "$@" "${init_conf%.conf}"
	fi
done