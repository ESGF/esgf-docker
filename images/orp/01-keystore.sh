#!/usr/bin/bash

set -eo pipefail

#####
## This script creates a keystore that Java understands from the hostcert
## and configures the ORP to use it
#####

ESGF_KEYSTORE_ALIAS="${ESGF_KEYSTORE_ALIAS:-esgf-self}"
ESGF_KEYSTORE_FILE="$ESGF_HOME/tomcat/hostcert.p12"
# Generate a random keystore password for this container run
ESGF_KEYSTORE_PASSWORD="$(openssl rand -hex 32)"

# Create the keystore
echo "[info] Creating PKCS12 bundle for host certificate and key"
mkdir -p "$(dirname "$ESGF_KEYSTORE_FILE")"
openssl pkcs12 -export \
    -name "$ESGF_KEYSTORE_ALIAS" \
    -out "$ESGF_KEYSTORE_FILE" \
    -in "$ESGF_HOSTCERT_DIR/tls.crt" \
    -inkey "$ESGF_HOSTCERT_DIR/tls.key" \
    -password "pass:$ESGF_KEYSTORE_PASSWORD"

# Configure the ORP to use it
echo "[info] Configuring ORP for PKCS12 bundle"
cat <<EOF > "$CATALINA_HOME/webapps/esg-orp/WEB-INF/classes/esg-orp.properties"
keystoreFile=$ESGF_KEYSTORE_FILE
keystorePassword=$ESGF_KEYSTORE_PASSWORD
keystoreAlias=$ESGF_KEYSTORE_ALIAS

orp.provider.list=$ESGF_CONFIG_DIR/esgf_known_providers.xml
EOF
