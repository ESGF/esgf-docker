#!/bin/bash

set -eo pipefail

function info { echo "[INFO] $1"; }
function error { echo "[ERROR] $1"; exit 1; }

#####
## This script sets up the THREDDS content root directory from a skeleton
##
## We need to do this because, in order to be persistent, the THREDDS content
## directory should be mounted in. However, we cannot rely on the Docker volumes
## behaviour of copying existing content to an empty volume, as this does not
## happen with volumes in Kubernetes
#####

# Make sure the directory exists
info "Ensuring THREDDS content root exists"
mkdir -p /esg/content/thredds/esgcet

# Sync the skeleton to the actual content directory
# The --ignore-existing flag should make sure any existing files are not overwritten
info "Copying any missing configuration files"
rsync -a --ignore-existing /esg/content/thredds-skel/ /esg/content/thredds

# Make sure the Tomcat user owns the THREDDS content root
info "Transferring ownership of THREDDS content root to Tomcat"
chown -R tomcat:tomcat /esg/content/thredds

info "Interpolating THREDDS web.xml"
# These variables are required in additional to those already set by interpolate-configs.sh
# from esgf-configure, which runs before this script
: ${ESGF_TRUSTSTORE_FILE:="/esg/config/tomcat/esg-truststore.ts"}
# Allow password to come from a file to allow the use of Docker secrets
if [ -z "$ESGF_TRUSTSTORE_PASSWORD" ]; then
    [ -z "$ESGF_TRUSTSTORE_PASSWORD_FILE" ] && \
        error "ESGF_TRUSTSTORE_PASSWORD or ESGF_TRUSTSTORE_PASSWORD_FILE must be set"
    [ -f "$ESGF_TRUSTSTORE_PASSWORD_FILE" ] || \
        error "ESGF_TRUSTSTORE_PASSWORD_FILE does not exist"
    ESGF_TRUSTSTORE_PASSWORD="$(cat "$ESGF_TRUSTSTORE_PASSWORD_FILE")"
fi
: ${ESGF_AUTH_URL:="https://${ESGF_HOSTNAME}/esgf-auth"}
# Allow secret key to come from a file to allow the use of Docker secrets
if [ -z "$ESGF_COOKIE_SECRET_KEY" ]; then
    [ -z "$ESGF_COOKIE_SECRET_KEY_FILE" ] && \
        error "ESGF_COOKIE_SECRET_KEY or ESGF_COOKIE_SECRET_KEY_FILE must be set"
    [ -f "$ESGF_COOKIE_SECRET_KEY_FILE" ] || \
        error "ESGF_COOKIE_SECRET_KEY_FILE does not exist"
    ESGF_COOKIE_SECRET_KEY="$(cat "$ESGF_COOKIE_SECRET_KEY_FILE")"
fi

export ESGF_TRUSTSTORE_FILE \
       ESGF_TRUSTSTORE_PASSWORD \
       ESGF_AUTH_URL \
       ESGF_COOKIE_SECRET_KEY

# Because Kubernetes configmaps can't do binary, decode the truststore from base64
# if the file only exists with a .base64 extension
BASE64_TRUSTSTORE_FILE="$ESGF_TRUSTSTORE_FILE.base64"
if [ ! -f "$ESGF_TRUSTSTORE_FILE" ] && [ -f "$BASE64_TRUSTSTORE_FILE" ]; then
    base64 --decode < "$BASE64_TRUSTSTORE_FILE" > "$ESGF_TRUSTSTORE_FILE"
fi

THREDDS_WEB_XML="$CATALINA_HOME/webapps/thredds/WEB-INF/web.xml"
# If the web.xml already contains the string "esg.orp", assume it has been mounted in
# This string would never be in a standard THREDDS config
grep -q "esg.orp" "$THREDDS_WEB_XML" || envsubst < "${THREDDS_WEB_XML}.template" > "$THREDDS_WEB_XML"
