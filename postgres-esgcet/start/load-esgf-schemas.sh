#!/bin/bash

set -eo pipefail

function error { echo "[ERROR] $1" 1>&2; exit 1; }

#####
## Start hook that loads the ESGF schemas
#####

if ${PG_INITIALIZED:-false} ; then
    # If we are initialising, create the esgcet user and load the ESGF schemas
    psql=( psql -v ON_ERROR_STOP=1 )
    # Create the esgcet user
    "${psql[@]}" --command "CREATE USER esgcet;"
    # Load ESGF schemas
    psql+=( --dbname "$POSTGRESQL_DATABASE" )
    sqldir="$(dirname "$BASH_SOURCE")"
    "${psql[@]}" -f "${sqldir}/esgf_esgcet.sql"
    "${psql[@]}" -f "${sqldir}/esgf_node_manager.sql"
    "${psql[@]}" -f "${sqldir}/esgf_security.sql"
    "${psql[@]}" -f "${sqldir}/esgf_dashboard.sql"
    "${psql[@]}" -f "${sqldir}/esgf_migrate_version.sql"
    # Create the rootAdmin account from environment variables
    "${psql[@]}" -f - <<ESGF_SECURITY_DATA
-- load the pgcrypto and UUID functions
CREATE EXTENSION IF NOT EXISTS "pgcrypto";
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

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
fi

# Update the password for the esgcet user
psql -v ON_ERROR_STOP=1 --command "ALTER USER esgcet WITH ENCRYPTED PASSWORD '${ESGF_ESGCET_PASSWORD}';"
