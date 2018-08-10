#!/bin/bash

# The -u causes the script to fail if we use a variable that is not set
set -euo pipefail

. /esg/bin/functions.sh

info "Creating PKCS12 bundle for host certificate and private key"
export ESGF_KEYSTORE_FILE="$CATALINA_HOME/conf/hostcert.p12"
# Generate a random keystore password for this container run
export ESGF_KEYSTORE_PASSWORD="$(echo -n "$(cat /dev/urandom | tr -dc '[:alnum:]' | head -c "20")")"
openssl pkcs12 -export \
    -name "$ESGF_KEYSTORE_ALIAS" \
    -out "$ESGF_KEYSTORE_FILE" \
    -in "$ESGF_SAML_CERT_FILE" \
    -inkey "$ESGF_SAML_KEY_FILE" \
    -password "pass:$ESGF_KEYSTORE_PASSWORD"

# Build the /esg/config directory
/esg/bin/build-config.sh /esg/config
# Then build the esg-orp.properties
/esg/bin/build-config.sh "$CATALINA_HOME/webapps/esg-orp/WEB-INF/classes"
