#!/bin/bash

set -e

function error { echo "[ERROR] $1" 1>&2 ; exit 1; }

#####
## Work out values for the environment to insert into config files
#####
: ${ESGF_COG_SITE_NAME:="Local CoG"}

[ -z "$ESGF_COG_DOMAIN" ] && error "ESGF_COG_DOMAIN must be specified"

: ${ESGF_COG_TIME_ZONE:="America/Denver"}

if [ -z "$ESGF_COG_SECRET_KEY" ]; then
    [ -z "$ESGF_COG_SECRET_KEY_FILE" ] && \
        error "ESGF_COG_SECRET_KEY or ESGF_COG_SECRET_KEY_FILE must be specified"
    [ -f "$ESGF_COG_SECRET_KEY_FILE" ] || \
        error "ESGF_COG_SECRET_KEY_FILE does not exist"
    ESGF_COG_SECRET_KEY="$(cat "$ESGF_COG_SECRET_KEY_FILE")"
fi

[ -z "$ESGF_COG_DATABASE_HOST" ] && error "ESGF_COG_DATABASE_HOST must be specified"
: ${ESGF_COG_DATABASE_PORT:="5432"}
: ${ESGF_COG_DATABASE_NAME:="esgcet"}
: ${ESGF_COG_DATABASE_USER:="dbsuper"}
if [ -z "$ESGF_COG_DATABASE_PASSWORD" ]; then
    [ -z "$ESGF_COG_DATABASE_PASSWORD_FILE" ] && \
        error "ESGF_COG_DATABASE_PASSWORD or ESGF_COG_DATABASE_PASSWORD_FILE must be specified"
    [ -f "$ESGF_COG_DATABASE_PASSWORD_FILE" ] || \
        error "ESGF_COG_DATABASE_PASSWORD_FILE does not exist"
    ESGF_COG_DATABASE_PASSWORD="$(cat "$ESGF_COG_DATABASE_PASSWORD_FILE")"
fi

[ -z "$ESGF_SEARCH_URL" ] && error "ESGF_SEARCH_URL must be specified"

: ${ESGF_COG_ALLOWED_HOSTS:="$ESGF_COG_DOMAIN"}

[ -z "$ESGF_IDP_URL" ] && error "ESGF_IDP_URL must be specified"

: ${ESGF_COG_PRODUCTION:="True"}

# Make sure all the variables have been exported
export ESGF_COG_SITE_NAME \
       ESGF_COG_DOMAIN \
       ESGF_COG_TIME_ZONE \
       ESGF_COG_SECRET_KEY \
       ESGF_COG_DATABASE_HOST \
       ESGF_COG_DATABASE_PORT \
       ESGF_COG_DATABASE_NAME \
       ESGF_COG_DATABASE_USER \
       ESGF_COG_DATABASE_PASSWORD \
       ESGF_SEARCH_URL \
       ESGF_COG_ALLOWED_HOSTS \
       ESGF_IDP_URL \
       ESGF_COG_PRODUCTION


#####
## Interpolate configuration files with values from the environment where required
##
## If the actual config files already exist, i.e. because they have been mounted
## in, use them in preference
#####
COG_SETTINGS_FILE="$COG_CONFIG_DIR/cog_settings.cfg"
[ -f "$COG_SETTINGS_FILE" ] || envsubst < "$COG_SETTINGS_FILE.template" > "$COG_SETTINGS_FILE"

ESGF_IDP_FILE="/esg/config/esgf_idp.xml"
[ -f "$ESGF_IDP_FILE" ] || envsubst < "$ESGF_IDP_FILE.template" > "$ESGF_IDP_FILE"

ESGF_ROOTADMIN_PASSWORD_FILE="/esg/config/.esgf_pass"
if [ ! -f "$ESGF_ROOTADMIN_PASSWORD_FILE" ]; then
    [ -z "$ESGF_ROOTADMIN_PASSWORD" ] && \
        error "$ESGF_ROOTADMIN_PASSWORD_FILE must exist or ESGF_ROOTADMIN_PASSWORD must be set"
    echo "$ESGF_ROOTADMIN_PASSWORD" > $ESGF_ROOTADMIN_PASSWORD_FILE
fi
