#!/bin/bash
set -e
apt-get clean
find /var/run /var/mail /var/spool /var/lock /var/backups /var/tmp -type f -exec rm '{}' ';'
find /var/log -type f -name '*.gz' -exec rm '{}' ';'
find /var/log -type f -name '*[0-9]' -exec rm '{}' ';'
find /var/log -type f -exec truncate --size=0 '{}' ';'
rm -f /var/lib/apt/lists/*{Packages,Release,Sources}*
rm -rf /tmp/* 2>/dev/null
