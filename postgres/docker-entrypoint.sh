#!/bin/sh
####
## This file is the Docker entrypoint for this container.
##
## It runs the database initialisation (if required) before execing postgres
####

set -e

# If running as root, do some permissions
if [ "$(id -u)" = "0" ]; then
    mkdir -p "$PGDATA"
    chown -R postgres:postgres "$PGDATA"
    chmod 700 "$PGDATA"

    # Run this script again as the postgres user
    exec gosu postgres "$BASH_SOURCE" "$@"
fi

# If postgres is not setup, set it up
# Check for the presence of a sentinel file to know
if [ ! -s "$PGDATA/PG_VERSION" ]; then
    # These variables can be specified directly or, to allow support for Docker
    # secrets (which can only be mounted as files), a variable telling us where
    # to read them from
    if [ -z "$DBSUPER_PASSWORD" ]; then
        [ -z "$DBSUPER_PASSWORD_FILE" ] && {
            echo "[ERROR] DBSUPER_PASSWORD or DBSUPER_PASSWORD_FILE must be set" 1>&2
            exit 1
        }
        [ -f "$DBSUPER_PASSWORD_FILE" ] || {
            echo "[ERROR] DBSUPER_PASSWORD_FILE does not exist" 1>&2
            exit 1
        }
        DBSUPER_PASSWORD="$(cat "$DBSUPER_PASSWORD_FILE")"
    fi
    if [ -z "$ESGCET_PASSWORD" ]; then
        [ -z "$ESGCET_PASSWORD_FILE" ] && {
            echo "[ERROR] ESGCET_PASSWORD or ESGCET_PASSWORD_FILE must be set" 1>&2
            exit 1
        }
        [ -f "$ESGCET_PASSWORD_FILE" ] || {
            echo "[ERROR] ESGCET_PASSWORD_FILE does not exist" 1>&2
            exit 1
        }
        ESGCET_PASSWORD="$(cat "$ESGCET_PASSWORD_FILE")"
    fi

    # Initialise the database
    initdb -U postgres -D "$PGDATA"
    # Ensure that the auth method is md5 for remote hosts
    echo $'\nhost all all 0.0.0.0/0 md5' >> "$PGDATA/pg_hba.conf"

    #####
    # ESGF-specific setup
    #
    # TODO: Move this into the application containers
    #####
    # Start postgres locally to allow us to run psql commands
    pg_ctl -U postgres -D "$PGDATA" -o "-h '127.0.0.1'" -w start

    psql=( psql -v ON_ERROR_STOP=1 -U postgres )
    # create super user
    "${psql[@]}" -c "CREATE USER dbsuper with CREATEROLE superuser PASSWORD '$DBSUPER_PASSWORD';"
    # create 'esgcet' user
    "${psql[@]}" -c "CREATE USER esgcet PASSWORD '$ESGCET_PASSWORD';"
    # create CoG database
    "${psql[@]}" -c "CREATE DATABASE cogdb;"
    # create ESGF database
    "${psql[@]}" -c "CREATE DATABASE esgcet;"
    # load ESGF schemas
    "${psql[@]}" -d esgcet -f /usr/local/bin/esgf_esgcet.sql
    "${psql[@]}" -d esgcet -f /usr/local/bin/esgf_node_manager.sql
    "${psql[@]}" -d esgcet -f /usr/local/bin/esgf_security.sql
    "${psql[@]}" -d esgcet -f /usr/local/bin/esgf_dashboard.sql
    # load ESGF data
    "${psql[@]}" -d esgcet -f /usr/local/bin/esgf_security_data.sql
    # initialize migration table
    "${psql[@]}" -d esgcet -f /usr/local/bin/esgf_migrate_version.sql

    # Stop the local postgres server
    pg_ctl -D "$PGDATA" -m fast -w stop

    echo
    echo "PostgreSQL initialisation complete."
    echo
fi

# Finally, execute the given command as the postgres user
exec "$@"
