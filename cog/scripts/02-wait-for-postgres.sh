#!/bin/bash

function error { echo "[ERROR] $1" 1>&2 ; exit 1; }

#####
# Script to wait untill connection to the Postgres container is ready
#####

export PGHOST="$ESGF_DATABASE_HOST"
export PGPORT="$ESGF_DATABASE_PORT"
export PGDATABASE="$ESGF_DATABASE_NAME"
export PGUSER="$ESGF_DATABASE_USER"
export PGPASSWORD="${ESGF_DATABASE_PASSWORD:-"$(cat "/esg/config/.esg_pg_pass")"}"

# Wait up to 5 minutes for postgres to become available
WAIT=5
TRIES=60
connected=0
for i in $(seq 1 $TRIES); do
    if psql -c "select 1" > /dev/null 2>&1; then
        connected=1
        break
    fi
    echo "[INFO] Waiting for connection to $ESGF_DATABASE_HOST..."
    sleep $WAIT
done
if [ "$connected" -eq "1" ]; then
    echo "[INFO] Connected to $ESGF_DATABASE_HOST"
else
    echo "[ERROR] Failed to connect to $ESGF_DATABASE_HOST" 1>&2
    exit 1
fi
