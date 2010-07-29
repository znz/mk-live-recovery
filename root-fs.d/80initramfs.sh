#!/bin/bash
set -e
depmod -a $(uname -r)
update-initramfs -u -k $(uname -r)
