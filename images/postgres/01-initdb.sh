#!/usr/bin/bash

set -eo pipefail

#####
## This script initialises the database if required
##
## It sets an environment variable, DB_INITIALISED, to true if initialisation
## was performed. This can be used by later startup scripts to determine if they
## need to take action.
#####

# The default user is postgres
export POSTGRES_USER="${POSTGRES_USER:-postgres}"
# The default database name is the same as the user
export POSTGRES_DATABASE="${POSTGRES_DATABASE:-$POSTGRES_USER}"
# The password may come from a file
if [ -z "$POSTGRES_PASSWORD" ] && [ -n "$POSTGRES_PASSWORD_FILE" ]; then
    POSTGRES_PASSWORD="$(< "$POSTGRES_PASSWORD_FILE")"
fi
# The password is required
if [ -z "$POSTGRES_PASSWORD" ]; then
    echo "[fatal] Either POSTGRES_PASSWORD or POSTGRES_PASSWORD_FILE is required" 1>&2
    exit 1
fi
export POSTGRES_PASSWORD

if [ ! -d "$PGDATA" ]; then
    echo "[fatal] $PGDATA is not a directory" 1>&2
    exit 1
fi

if [ ! -w "$PGDATA" ]; then
    echo "[fatal] $PGDATA is not writable by $(id -u -n)" 1>&2
    exit 1
fi

if [ -s "$PGDATA/PG_VERSION" ]; then
    echo "[warn] $PGDATA already contains a database - skipping initialisation"
    export DB_INITIALISED=false
    return 0
fi

export DB_INITIALISED=true

echo "[info] Fixing permissions for $PGDATA"
ls -l /var/lib
ls -l /var/lib/pgsql
chown $ESG_USER:$ESG_GROUP "$PGDATA"
chmod 700 "$PGDATA"

echo "[info] Initialising database in $PGDATA"
eval 'initdb --username="$POSTGRES_USER" --pwfile=<(echo "$POSTGRES_PASSWORD") '"$POSTGRES_INITDB_ARGS"

echo "[info] Starting local server"
export PGUSER="$POSTGRES_USER"
export PGPASSWORD="$POSTGRES_PASSWORD"
pg_ctl -D "$PGDATA" -o "-c listen_addresses='' -p $PGPORT" -w start

if [ "$POSTGRES_DATABASE" != 'postgres' ]; then
    echo "[info] Creating database - $POSTGRES_DATABASE"
    psql -v ON_ERROR_STOP=1 --dbname postgres --set db="$POSTGRES_DATABASE" <<< 'CREATE DATABASE :"db" ;'
fi

echo "[info] Running database setup scripts from $ESG_INIT_DB_DIR"
psql=( psql -v ON_ERROR_STOP=1 --dbname "$POSTGRES_DATABASE" )
if [ -d "$ESG_INIT_DB_DIR" ]; then
    for file in $(find $ESG_INIT_DB_DIR -mindepth 1 -type f | sort -n); do
        echo "[info] Running database setup from $file"
        case "$file" in
            *.sh) source $file ;;
            *.sql) "${psql[@]}" -f "$file" ;;
            *.sql.gz) gunzip -c "$file" | "${psql[@]}" ;;
            *) "[warn] Ignoring $file - file is not .sh, .sql or .sql.gz" ;;
        esac
    done
fi

echo "[info] Stopping local server"
pg_ctl -D "$PGDATA" -m fast -w stop

unset PGUSER PGPASSWORD
echo "[info] Database initialisation complete!"
