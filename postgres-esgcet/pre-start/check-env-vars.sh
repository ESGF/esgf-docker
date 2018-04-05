#!/bin/sh

set -eo pipefail

function error { echo "[ERROR] $1" 1>&2; exit 1; }

#####
## This script checks that any extra environment variables we need are set
#####

# Check that the password for the esgcet user has been configured
if [ -z "${ESGF_ESGCET_PASSWORD:-}" ]; then
    [ -z "${ESGF_ESGCET_PASSWORD_FILE:-}" ] && error "ESGF_ESGCET_PASSWORD or ESGF_ESGCET_PASSWORD_FILE must be set"
    [ -f "$ESGF_ESGCET_PASSWORD_FILE" ] || error "ESGF_ESGCET_PASSWORD_FILE does not exist"
    ESGF_ESGCET_PASSWORD="$(< "$ESGF_ESGCET_PASSWORD_FILE")"
fi

# Check that the rootAdmin data has been properly configured
[ -z "${ESGF_ROOTADMIN_EMAIL:-}" ] && error "ESGF_ROOTADMIN_EMAIL must be set"
[ -z "${ESGF_ROOTADMIN_USERNAME:-}" ] && error "ESGF_ROOTADMIN_USERNAME must be set"
[ -z "${ESGF_ROOTADMIN_OPENID:-}" ] && error "ESGF_ROOTADMIN_OPENID must be set"
if [ -z "${ESGF_ROOTADMIN_PASSWORD:-}" ]; then
    [ -z "${ESGF_ROOTADMIN_PASSWORD_FILE:-}" ] && error "ESGF_ROOTADMIN_PASSWORD or ESGF_ROOTADMIN_PASSWORD_FILE must be set"
    [ -f "$ESGF_ROOTADMIN_PASSWORD_FILE" ] || error "ESGF_ROOTADMIN_PASSWORD_FILE does not exist"
    ESGF_ROOTADMIN_PASSWORD="$(cat "$ESGF_ROOTADMIN_PASSWORD_FILE")"
fi

# Export the variables for the post-init scripts
export ESGF_ESGCET_PASSWORD \
       ESGF_ROOTADMIN_EMAIL \
       ESGF_ROOTADMIN_USERNAME \
       ESGF_ROOTADMIN_OPENID \
       ESGF_ROOTADMIN_PASSWORD
