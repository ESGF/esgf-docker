#!/bin/bash

set -eo pipefail

function error { echo "[ERROR] $1" 1>&2; exit 1; }


echo "[INFO] Checking environment"
[ -z "$ESGF_SAML_CERT_FILE" ] && error "ESGF_SAML_CERT_FILE must be set"
[ -z "$ESGF_SAML_KEY_FILE" ] && error "ESGF_SAML_KEY_FILE must be set"
: ${ESGF_KEYSTORE_ALIAS:="$ESGF_HOSTNAME"}

echo "[INFO] Creating PKCS12 bundle for host certificate and private key"
ESGF_KEYSTORE_FILE="/esg/certificates/hostcert.p12"
# Generate a random keystore password for this container run
ESGF_KEYSTORE_PASSWORD="$(echo -n "$(tr -dc '[:alnum:]' < /dev/urandom | head -c "20")")"
openssl pkcs12 -export \
    -name "$ESGF_KEYSTORE_ALIAS" \
    -out "$ESGF_KEYSTORE_FILE" \
    -in "$ESGF_SAML_CERT_FILE" \
    -inkey "$ESGF_SAML_KEY_FILE" \
    -password "pass:$ESGF_KEYSTORE_PASSWORD"
chmod "g+r,o+r" "$ESGF_KEYSTORE_FILE"

export ESGF_KEYSTORE_FILE ESGF_KEYSTORE_ALIAS ESGF_KEYSTORE_PASSWORD

echo "[INFO] Creating esg-orp.properties"

# Write the esg-orp.properties file using values from the environment variables
ESG_ORP_PROPS="$CATALINA_HOME/webapps/esg-orp/WEB-INF/classes/esg-orp.properties"
grep -q '@@keystoreFile@@' "$ESG_ORP_PROPS" && envsubst < "${ESG_ORP_PROPS}.template" > "$ESG_ORP_PROPS"
