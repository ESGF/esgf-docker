#!/bin/bash

set -eo pipefail

function error { echo "[ERROR] $1" 1>&2; exit 1; }


[ -z "$ESGF_KEYSTORE_FILE" ] && error "ESGF_KEYSTORE_FILE must be set"
[ -z "$ESGF_KEYSTORE_ALIAS" ] && error "ESGF_KEYSTORE_ALIAS must be set"
# To support Docker secrets which, unlike Kubernetes, can only be mounted as files,
# read the value of ESGF_KEYSTORE_PASSWORD from ESGF_KEYSTORE_PASSWORD_FILE if
# not given as an environment variable
if [ -z "$ESGF_KEYSTORE_PASSWORD" ]; then
    [ -z "$ESGF_KEYSTORE_PASSWORD_FILE" ] && \
        error "ESGF_KEYSTORE_PASSWORD or ESGF_KEYSTORE_PASSWORD_FILE must be set"
    [ -f "$ESGF_KEYSTORE_PASSWORD_FILE" ] || \
        error "ESGF_KEYSTORE_PASSWORD_FILE does not exist"
    ESGF_KEYSTORE_PASSWORD="$(cat "$ESGF_KEYSTORE_PASSWORD_FILE")"
fi

export ESGF_KEYSTORE_FILE ESGF_KEYSTORE_ALIAS ESGF_KEYSTORE_PASSWORD

echo "[INFO] Creating esg-orp.properties"

# Write the esg-orp.properties file using values from the environment variables
ESG_ORP_PROPS="$CATALINA_HOME/webapps/esg-orp/WEB-INF/classes/esg-orp.properties"
grep -q '@@keystoreFile@@' "$ESG_ORP_PROPS" && envsubst < "${ESG_ORP_PROPS}.template" > "$ESG_ORP_PROPS"
