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

# Make sure all the variables have been exported
export ESGF_COG_SITE_NAME \
       ESGF_COG_TIME_ZONE \
       ESGF_COG_SECRET_KEY \
       ESGF_COG_HOME_PROJECT

#####
## Interpolate the cog_settings.cfg template with values from the environment
##
## If the actual config file already exists, i.e. because it has been mounted
## in, use it in preference
#####
COG_SETTINGS_FILE="$COG_CONFIG_DIR/cog_settings.cfg"
[ -f "$COG_SETTINGS_FILE" ] || envsubst < "$COG_SETTINGS_FILE.template" > "$COG_SETTINGS_FILE"
