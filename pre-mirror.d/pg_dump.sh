#!/bin/bash
set -eu

umask 077
PG_BACKUP_DIR=${PG_BACKUP_DIR:-/home/pg_backup}
PG_DUMP="/usr/bin/pg_dump -O" 

if [ -f /etc/default/mk-live-recovery ]; then
    . /etc/default/mk-live-recovery
fi

check_pg_database () {
    if ! id -u postgres >/dev/null 2>&1; then
	echo postgres not installed
	return 1
    fi

    PG_DATABASES=$($SUDO_CMD su postgres -c "psql -c 'SELECT datname FROM pg_database;'" | egrep '^ [^ ]' | egrep -v '^ template[01]$|^ postgres$')
}

postgresql_dump_all () {
    if ! check_pg_database; then
        return
    fi

    $SUDO_CMD mkdir -p "$PG_BACKUP_DIR"
    $SUDO_CMD savelog -q "$PG_BACKUP_DIR/psql-l.txt" 
    $SUDO_CMD su postgres -c "psql -l" | $SUDO_CMD tee "$PG_BACKUP_DIR/psql-l.txt" > /dev/null
    for db_name in $PG_DATABASES; do
	$SUDO_CMD savelog -q "$PG_BACKUP_DIR/$db_name.pg_dump" 
        $SUDO_CMD su postgres -c "$PG_DUMP $db_name" | $SUDO_CMD tee "$PG_BACKUP_DIR/$db_name.pg_dump" > /dev/null
    done
}

case "$1" in
    data)
	set -x
	postgresql_dump_all
	;;
esac
