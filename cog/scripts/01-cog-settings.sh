#!/bin/bash

set -eo pipefail

function error { echo "[ERROR] $1" 1>&2 ; exit 1; }

# Call out to the main ESGF configuration first
. /opt/esgf-docker/scripts/interpolate-configs.sh


echo "[INFO] Interpolating cog_settings.cfg"

#####
## Find/calculate CoG specific variables
#####
: ${ESGF_COG_SITE_NAME:="Local CoG"}
: ${ESGF_COG_TIME_ZONE:="America/Denver"}
if [ -z "$ESGF_COG_SECRET_KEY" ]; then
    [ -z "$ESGF_COG_SECRET_KEY_FILE" ] && \
        error "ESGF_COG_SECRET_KEY or ESGF_COG_SECRET_KEY_FILE must be specified"
    [ -f "$ESGF_COG_SECRET_KEY_FILE" ] || \
        error "ESGF_COG_SECRET_KEY_FILE does not exist"
    ESGF_COG_SECRET_KEY="$(cat "$ESGF_COG_SECRET_KEY_FILE")"
fi
: ${ESGF_COG_HOME_PROJECT:="TestProject"}
# CoG database settings
# Use the ESGF settings by default
: ${ESGF_COG_DATABASE_HOST:="$ESGF_DATABASE_HOST"}
: ${ESGF_COG_DATABASE_PORT:="$ESGF_DATABASE_PORT"}
: ${ESGF_COG_DATABASE_NAME:="cogdb"}
: ${ESGF_COG_DATABASE_USER:="$ESGF_DATABASE_USER"}
if [ -z "$ESGF_COG_DATABASE_PASSWORD" ]; then
    if [ -n "$ESGF_COG_DATABASE_PASSWORD_FILE" ]; then
        [ -f "$ESGF_COG_DATABASE_PASSWORD_FILE" ] || \
            error "ESGF_COG_DATABASE_PASSWORD_FILE does not exist"
        ESGF_COG_DATABASE_PASSWORD="$(cat "$ESGF_COG_DATABASE_PASSWORD_FILE")"
    else
        ESGF_COG_DATABASE_PASSWORD="$ESGF_DATABASE_PASSWORD"
    fi
fi

# Make sure all the variables have been exported
export ESGF_COG_SITE_NAME \
       ESGF_COG_TIME_ZONE \
       ESGF_COG_SECRET_KEY \
       ESGF_COG_HOME_PROJECT \
       ESGF_COG_DATABASE_HOST \
       ESGF_COG_DATABASE_PORT \
       ESGF_COG_DATABASE_NAME \
       ESGF_COG_DATABASE_USER \
       ESGF_COG_DATABASE_PASSWORD

#####
## Interpolate the cog_settings.cfg template with values from the environment
##
## If the actual config file already exists, i.e. because it has been mounted
## in, use it in preference
#####
COG_SETTINGS_FILE="$COG_CONFIG_DIR/cog_settings.cfg"
[ -f "$COG_SETTINGS_FILE" ] || envsubst < "$COG_SETTINGS_FILE.template" > "$COG_SETTINGS_FILE"
