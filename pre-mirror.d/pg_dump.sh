#!/bin/bash
set -eu

umask 077
PG_BACKUP_DIR=${PG_BACKUP_DIR:-/home/pg_backup}
PG_DUMP="/usr/bin/pg_dump -O" 

if [ -f /etc/default/mk-live-recovery ]; then
    . /etc/default/mk-live-recovery
fi

postgresql_dump_all () {
    if ! id -u postgres >/dev/null 2>&1; then
	echo postgres not installed
	return
    fi

    PG_DATABASES=$( su postgres -c "psql -c 'SELECT datname FROM pg_database;'" | egrep '^ [^ ]' | egrep -v '^ template[01]$|^ postgres$' )

    mkdir -p "$PG_BACKUP_DIR"
    savelog -q "$PG_BACKUP_DIR/psql-l.txt" 
    su postgres -c "psql -l" >"$PG_BACKUP_DIR/psql-l.txt" 
    for db_name in $PG_DATABASES; do
	savelog -q "$PG_BACKUP_DIR/$db_name.pg_dump" 
        su postgres -c "$PG_DUMP $db_name" >"$PG_BACKUP_DIR/$db_name.pg_dump" 
    done
}

case "$1" in
    data)
	set -x
	postgresql_dump_all
	;;
esac
