#!/bin/bash

set -eo pipefail

function info { echo "[INFO] $1"; }
function error { echo "[ERROR] $1"; exit 1; }

#####
## This script sets up the THREDDS config files
#####

# Initialise the THREDDS content
info "Ensuring THREDDS content root exists"
mkdir -p /esg/content/thredds/esgcet
# Sync the skeleton to the actual content directory
# The --ignore-existing flag should make sure any existing files are not overwritten
info "Copying any missing THREDDS configuration files"
rsync -a --ignore-existing /esg/content/thredds-skel/ /esg/content/thredds
# Make sure the Tomcat user owns the THREDDS content root
info "Transferring ownership of THREDDS content root to Tomcat"
chown -R tomcat:tomcat /esg/content/thredds

info "Interpolating THREDDS web.xml"

: ${ESGF_AUTH_URL:="https://${ESGF_HOSTNAME}/esgf-auth"}
# Allow secret key to come from a file to allow the use of Docker secrets
if [ -z "$ESGF_COOKIE_SECRET_KEY" ]; then
    [ -z "$ESGF_COOKIE_SECRET_KEY_FILE" ] && \
        error "ESGF_COOKIE_SECRET_KEY or ESGF_COOKIE_SECRET_KEY_FILE must be set"
    [ -f "$ESGF_COOKIE_SECRET_KEY_FILE" ] || \
        error "ESGF_COOKIE_SECRET_KEY_FILE does not exist"
    ESGF_COOKIE_SECRET_KEY="$(cat "$ESGF_COOKIE_SECRET_KEY_FILE")"
fi
: ${ESGF_TDS_ADMIN_USERNAME:="rootAdmin"}
# Allow admin password to come from a file to allow the use of Docker secrets
if [ -z "$ESGF_TDS_ADMIN_PASSWORD" ]; then
    [ -z "$ESGF_TDS_ADMIN_PASSWORD_FILE" ] && \
        error "ESGF_TDS_ADMIN_PASSWORD or ESGF_TDS_ADMIN_PASSWORD_FILE must be set"
    [ -f "$ESGF_TDS_ADMIN_PASSWORD_FILE" ] || \
        error "ESGF_TDS_ADMIN_PASSWORD_FILE does not exist"
    ESGF_TDS_ADMIN_PASSWORD="$(cat "$ESGF_TDS_ADMIN_PASSWORD_FILE")"
fi
ESGF_TDS_ADMIN_PASSWORD_DIGEST="$($CATALINA_HOME/bin/digest.sh -a sha-512 -h org.apache.catalina.realm.MessageDigestCredentialHandler "$ESGF_TDS_ADMIN_PASSWORD" | cut -d':' -f2)"

export ESGF_AUTH_URL \
       ESGF_COOKIE_SECRET_KEY \
       ESGF_TDS_ADMIN_USERNAME \
       ESGF_TDS_ADMIN_PASSWORD_DIGEST

THREDDS_WEB_XML="$CATALINA_HOME/webapps/thredds/WEB-INF/web.xml"
# If the web.xml already contains the string "esg.orp", assume it has been mounted in
# This string would never be in a standard THREDDS config
grep -q "esg.orp" "$THREDDS_WEB_XML" || envsubst < "${THREDDS_WEB_XML}.template" > "$THREDDS_WEB_XML"

TOMCAT_USERS_XML="$CATALINA_HOME/conf/tomcat-users.xml"
# Always replace the template in case the password has changed
envsubst < "${TOMCAT_USERS_XML}.template" > "$TOMCAT_USERS_XML"
