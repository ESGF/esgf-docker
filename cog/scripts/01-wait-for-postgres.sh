#!/bin/bash

function error { echo "[ERROR] $1" 1>&2 ; exit 1; }

#####
# Script to wait untill connection to the Postgres container is ready
#####

# Check database settings
[ -z "$ESGF_COG_DATABASE_HOST" ] && error "ESGF_COG_DATABASE_HOST must be specified"
: ${ESGF_COG_DATABASE_PORT:="5432"}
: ${ESGF_COG_DATABASE_NAME:="esgcet"}
: ${ESGF_COG_DATABASE_USER:="dbsuper"}
if [ -z "$ESGF_COG_DATABASE_PASSWORD" ]; then
    [ -z "$ESGF_COG_DATABASE_PASSWORD_FILE" ] && \
        error "ESGF_COG_DATABASE_PASSWORD or ESGF_COG_DATABASE_PASSWORD_FILE must be specified"
    [ -f "$ESGF_COG_DATABASE_PASSWORD_FILE" ] || \
        error "ESGF_COG_DATABASE_PASSWORD_FILE does not exist"
    ESGF_COG_DATABASE_PASSWORD="$(cat "$ESGF_COG_DATABASE_PASSWORD_FILE")"
fi

export PGHOST="$ESGF_COG_DATABASE_HOST"
export PGPORT="$ESGF_COG_DATABASE_PORT"
export PGDATABASE="$ESGF_COG_DATABASE_NAME"
export PGUSER="$ESGF_COG_DATABASE_USER"
export PGPASSWORD="$ESGF_COG_DATABASE_PASSWORD"

# Wait up to 5 minutes for postgres to become available
WAIT=5
TRIES=60
connected=0
for i in $(seq 1 $TRIES); do
    if psql -c "select 1" > /dev/null 2>&1; then
        connected=1
        break
    fi
    echo "[INFO] Waiting for connection to $ESGF_COG_DATABASE_HOST..."
    sleep $WAIT
done
if [ "$connected" -eq "1" ]; then
    echo "[INFO] Connected to $ESGF_COG_DATABASE_HOST"
else
    echo "[ERROR] Failed to connect to $ESGF_COG_DATABASE_HOST" 1>&2
    exit 1
fi
