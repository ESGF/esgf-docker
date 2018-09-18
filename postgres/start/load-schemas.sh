#!/bin/bash

set -eo pipefail

function error { echo "[ERROR] $1" 1>&2; exit 1; }

#####
## This hook loads and executes all .sql files in the same directory as itself
#####

if ${PG_INITIALIZED:-false} && [ -n "$POSTGRESQL_DATABASE" ] ; then
    # If we are initialising, create the esgcet user and load the ESGF schemas
    psql=( psql -v ON_ERROR_STOP=1 --dbname "$POSTGRESQL_DATABASE" )
    # Find all the SQL files in the same directory as this script and execute
    # them one by one, ordered by name
    sqldir="$(dirname "$BASH_SOURCE")"
    for sqlfile in $(find "$sqldir" -maxdepth 1 -type f -name '*.sql' | sort -n); do
        echo " Loading schema -> ${sqlfile}"
        "${psql[@]}" -f "$sqlfile"
    done
fi
