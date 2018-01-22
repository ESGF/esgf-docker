#!/bin/sh
####
## This file is the Docker entrypoint for this container.
##
## It runs the database initialisation (if required) before execing postgres
####

set -e

function error {
    echo "[ERROR] $1" 1>&2
    exit "${2:-1}"
}

# This function is to allow support for Docker secrets which, unlike Kubernetes,
# can only be mounted as files
function env_var {
    local varname="$1"
    local filevar="${varname}_FILE"
    # If the variable is already set, there is nothing to do
    [ -n "${!varname}" ] && return
    # Otherwise, load it from the file if it exists
    if [ -f "${!filevar}" ]; then
        val="$(cat ${!filevar})"
    fi
    export "$varname"="$val"
}

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
    # Check all the environment variables we require are present
    env_var "DBSUPER_PASSWORD"
    [ -z "$DBSUPER_PASSWORD" ] && error "DBSUPER_PASSWORD is not set."
    env_var "ESGCET_PASSWORD"
    [ -z "$ESGCET_PASSWORD" ] && error "ESGCET_PASSWORD is not set."

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
