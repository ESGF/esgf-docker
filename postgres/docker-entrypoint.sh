#!/bin/sh
####
## This file is the Docker entrypoint for this container.
##
## It runs the database initialisation (if required) before execing postgres
####

set -eo pipefail

function error { echo "[ERROR] $1" 1>&2; exit 1; }


# If running as root, do some permissions
if [ "$(id -u)" = "0" ]; then
    mkdir -p "$PGDATA"
    chown -R postgres:postgres "$PGDATA"
    chmod 700 "$PGDATA"

    # Run this script again as the postgres user
    exec gosu postgres "$BASH_SOURCE" "$@"
fi

# These variables can be specified directly or, to allow support for Docker
# secrets (which can only be mounted as files), a variable telling us where
# to read them from
if [ -z "$DBSUPER_PASSWORD" ]; then
    [ -z "$DBSUPER_PASSWORD_FILE" ] && error "DBSUPER_PASSWORD or DBSUPER_PASSWORD_FILE must be set"
    [ -f "$DBSUPER_PASSWORD_FILE" ] || error "DBSUPER_PASSWORD_FILE does not exist"
    DBSUPER_PASSWORD="$(cat "$DBSUPER_PASSWORD_FILE")"
fi
if [ -z "$ESGCET_PASSWORD" ]; then
    [ -z "$ESGCET_PASSWORD_FILE" ] && error "ESGCET_PASSWORD or ESGCET_PASSWORD_FILE must be set"
    [ -f "$ESGCET_PASSWORD_FILE" ] || error "ESGCET_PASSWORD_FILE does not exist"
    ESGCET_PASSWORD="$(cat "$ESGCET_PASSWORD_FILE")"
fi
# Check that the rootAdmin data has been properly configured
[ -z "$ESGF_ROOTADMIN_EMAIL" ] && error "ESGF_ROOTADMIN_EMAIL must be set"
[ -z "$ESGF_ROOTADMIN_USERNAME" ] && error "ESGF_ROOTADMIN_USERNAME must be set"
[ -z "$ESGF_ROOTADMIN_OPENID" ] && error "ESGF_ROOTADMIN_OPENID must be set"
if [ -z "$ESGF_ROOTADMIN_PASSWORD" ]; then
    [ -z "$ESGF_ROOTADMIN_PASSWORD_FILE" ] && error "ESGF_ROOTADMIN_PASSWORD or ESGF_ROOTADMIN_PASSWORD_FILE must be set"
    [ -f "$ESGF_ROOTADMIN_PASSWORD_FILE" ] || error "ESGF_ROOTADMIN_PASSWORD_FILE does not exist"
    ESGF_ROOTADMIN_PASSWORD="$(cat "$ESGF_ROOTADMIN_PASSWORD_FILE")"
fi

# If postgres is not setup, set it up
# Check for the presence of a sentinel file to know
if [ ! -s "$PGDATA/PG_VERSION" ]; then
    # Initialise the database
    initdb -U postgres -D "$PGDATA"
    # Ensure that the auth method is md5 for remote hosts
    echo $'\nhost all all 0.0.0.0/0 md5' >> "$PGDATA/pg_hba.conf"

    #####
    # ESGF-specific setup
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
    # initialize migration table
    "${psql[@]}" -d esgcet -f /usr/local/bin/esgf_migrate_version.sql
    # Insert data into the security table
    # We create the rootAdmin account with the given password
    "${psql[@]}" -d esgcet -f - <<ESGF_SECURITY_DATA
-- script to populate the esgf_security database with the required data

-- load the pgcrypto and UUID functions
\i /usr/share/pgsql/contrib/pgcrypto.sql
\i /usr/share/pgsql/contrib/uuid-ossp.sql

-- rootAdmin user
INSERT INTO esgf_security.user (
    firstname,
    lastname,
    email,
    username,
    password,
    dn,
    openid,
    organization,
    city,
    state,
    country,
    status_code,
    verification_token,
    notification_code
) VALUES (
    'Admin',
    'User',
    '$ESGF_ROOTADMIN_EMAIL',
    '$ESGF_ROOTADMIN_USERNAME',
    crypt('$ESGF_ROOTADMIN_PASSWORD', gen_salt('md5')),
    '',
    '$ESGF_ROOTADMIN_OPENID',
    'Institution',
    'City',
    'State',
    'Country',
    1,
    uuid_generate_v4(),
    0
);

-- groups
INSERT INTO esgf_security.group (name, description, visible, automatic_approval) VALUES ('wheel', 'Administrator Group', true, true);

-- roles
INSERT INTO esgf_security.role (name, description) VALUES ('super', 'Super User');
INSERT INTO esgf_security.role (name, description) VALUES ('user', 'Standard User');
INSERT INTO esgf_security.role (name, description) VALUES ('admin', 'Group Administrator');
INSERT INTO esgf_security.role (name, description) VALUES ('publisher', 'Data Publisher');
INSERT INTO esgf_security.role (name, description) VALUES ('test', 'Test Role');
INSERT INTO esgf_security.role (name, description) VALUES ('none', 'None');

-- make rootAdmin a super user for the wheel group
INSERT INTO esgf_security.permission (user_id, group_id, role_id, approved) VALUES (
    (SELECT id FROM esgf_security.user WHERE username = '$ESGF_ROOTADMIN_USERNAME'),
    (SELECT id FROM esgf_security.group WHERE name = 'wheel'),
    (SELECT id FROM esgf_security.role WHERE name = 'super'),
    true
);
ESGF_SECURITY_DATA

    # Stop the local postgres server
    pg_ctl -D "$PGDATA" -m fast -w stop

    echo
    echo "PostgreSQL initialisation complete."
    echo
else
    #####
    # If postgres is already setup, just make sure the user passwords match
    #####
    # Start postgres locally to allow us to run psql commands
    pg_ctl -U postgres -D "$PGDATA" -o "-h '127.0.0.1'" -w start
    # Execute the password update commands
    psql=( psql -v ON_ERROR_STOP=1 -U postgres )
    "${psql[@]}" -c "ALTER USER dbsuper WITH PASSWORD '$DBSUPER_PASSWORD';"
    # create 'esgcet' user
    "${psql[@]}" -c "ALTER USER esgcet WITH PASSWORD '$ESGCET_PASSWORD';"
    # Stop the local postgres server
    pg_ctl -D "$PGDATA" -m fast -w stop
fi

# Finally, execute the given command as the postgres user
exec "$@"
