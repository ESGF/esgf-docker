#!/bin/bash

#####
# Script to wait until connection to the Postgres container is ready
#####

# This setting will cause the script to fail if we try to access an undefined variable
set -eu

# Create a password file for Postgres commands to use
export PGPASSFILE="$(mktemp)"
echo "$ESGF_DATABASE_HOST:$ESGF_DATABASE_PORT:$ESGF_DATABASE_NAME:$ESGF_DATABASE_USER:$(< "/esg/config/.esg_pg_pass")" > $PGPASSFILE
echo "$ESGF_COG_DATABASE_HOST:$ESGF_COG_DATABASE_PORT:$ESGF_COG_DATABASE_NAME:$ESGF_COG_DATABASE_USER:$(< "$ESGF_COG_DATABASE_PASSWORD_FILE")" >> $PGPASSFILE

# Try to connect to the esgcet database, and bail on failure
if ! pg_isready --host="$ESGF_DATABASE_HOST" \
                --port="$ESGF_DATABASE_PORT" \
                --dbname="$ESGF_DATABASE_NAME" \
                --username="$ESGF_DATABASE_USER"
then
    echo "[ERROR] Failed to connect to $ESGF_DATABASE_HOST" 1>&2
    exit 1
fi

# Try to connect to the cog database, and bail on failure
if ! pg_isready --host="$ESGF_COG_DATABASE_HOST" \
                --port="$ESGF_COG_DATABASE_PORT" \
                --dbname="$ESGF_COG_DATABASE_NAME" \
                --username="$ESGF_COG_DATABASE_USER"
then
    echo "[ERROR] Failed to connect to $ESGF_COG_DATABASE_HOST" 1>&2
    exit 1
fi

rm -rf $PGPASSFILE
unset PGPASSFILE
