#!/bin/bash
if [ "${LOCAL_TEST:+set}" != set ]; then
	exit
fi
{
	echo "/usr/share/doc/*" # exclude documents when test
	echo "/usr/src/*" # exclude src when test
} | xargs -n1 -- printf -- '- %s\n'
