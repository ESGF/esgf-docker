#!/bin/bash

#####
# Script to wait untill connection to the Postgres container is ready
#####

export PGHOST="$ESGF_DATABASE_HOST"
export PGPORT="$ESGF_DATABASE_PORT"
export PGDATABASE="$ESGF_DATABASE_NAME"
export PGUSER="$ESGF_DATABASE_USER"
export PGPASSWORD="${ESGF_DATABASE_PASSWORD:-"$(cat "/esg/config/.esg_pg_pass")"}"

# Try to connect to Postgres, and bail on failure
if ! psql -c "select 1" > /dev/null 2>&1; then
    echo "[ERROR] Failed to connect to $ESGF_DATABASE_HOST" 1>&2
    exit 1
fi
