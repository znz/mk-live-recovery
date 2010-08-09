#!/bin/bash
{
	echo "/usr/share/doc/*" # exclude documents when test
	echo "/usr/src/*" # exclude src when test
} | xargs -n1 -- printf -- '- %s\n'
