#!/bin/bash

set -eo pipefail

function error { echo "[ERROR] $1" 1>&2 ; exit 1; }

#####
## Populate the auth config files using environment variables
#####

[ -z "$ESGF_HOSTNAME" ] && error "ESGF_HOSTNAME must be set"
# Allow secrets to come from a file to allow the use of Docker secrets
if [ -z "$ESGF_AUTH_SECRET_KEY" ]; then
    [ -z "$ESGF_AUTH_SECRET_KEY_FILE" ] && \
        error "ESGF_AUTH_SECRET_KEY or ESGF_AUTH_SECRET_KEY_FILE must be set"
    [ -f "$ESGF_AUTH_SECRET_KEY_FILE" ] || \
        error "ESGF_AUTH_SECRET_KEY_FILE does not exist"
    ESGF_AUTH_SECRET_KEY="$(cat "$ESGF_AUTH_SECRET_KEY_FILE")"
fi
if [ -z "$ESGF_COOKIE_SECRET_KEY" ]; then
    [ -z "$ESGF_COOKIE_SECRET_KEY_FILE" ] && \
        error "ESGF_COOKIE_SECRET_KEY or ESGF_COOKIE_SECRET_KEY_FILE must be set"
    [ -f "$ESGF_COOKIE_SECRET_KEY_FILE" ] || \
        error "ESGF_COOKIE_SECRET_KEY_FILE does not exist"
    ESGF_COOKIE_SECRET_KEY="$(cat "$ESGF_COOKIE_SECRET_KEY_FILE")"
fi

export ESGF_HOSTNAME ESGF_AUTH_SECRET_KEY ESGF_COOKIE_SECRET_KEY


[ -f "$ESGF_AUTH_CONFIG_FILE" ] || envsubst < "${ESGF_AUTH_CONFIG_FILE}.template" > "$ESGF_AUTH_CONFIG_FILE"
