#!/bin/sh

set -eo pipefail

function error { echo "[ERROR] $1" 1>&2; exit 1; }

#####
## This script checks that any extra environment variables we need are set
#####

# Check that the rootAdmin data has been properly configured
[ -z "${ESGF_ROOTADMIN_EMAIL:-}" ] && error "ESGF_ROOTADMIN_EMAIL must be set"
[ -z "${ESGF_ROOTADMIN_USERNAME:-}" ] && error "ESGF_ROOTADMIN_USERNAME must be set"
[ -z "${ESGF_ROOTADMIN_OPENID:-}" ] && error "ESGF_ROOTADMIN_OPENID must be set"
if [ -z "${ESGF_ROOTADMIN_PASSWORD:-}" ]; then
    [ -z "${ESGF_ROOTADMIN_PASSWORD_FILE:-}" ] && error "ESGF_ROOTADMIN_PASSWORD or ESGF_ROOTADMIN_PASSWORD_FILE must be set"
    [ -f "$ESGF_ROOTADMIN_PASSWORD_FILE" ] || error "ESGF_ROOTADMIN_PASSWORD_FILE does not exist"
    export ESGF_ROOTADMIN_PASSWORD="$(< "$ESGF_ROOTADMIN_PASSWORD_FILE")"
fi

# Create the schema file
cat > "$APP_DATA/src/postgresql-start/02-rootadmin.sql" <<ESGF_SECURITY_DATA
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
