#!/bin/bash
if [ "${LOCAL_TEST:+set}" != set ]; then
	exit
fi
{
	echo "/usr/lib/vmware-tools/modules/binary"
} | xargs -n1 -- printf -- '- %s\n'
