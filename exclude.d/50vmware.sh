#!/bin/bash
{
	echo "/usr/lib/vmware-tools/modules/binary"
} | xargs -n1 -- printf -- '- %s\n'
