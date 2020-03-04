#!/usr/bin/bash

set -eo pipefail

#####
## This script creates a keystore that Java understands from the hostcert
## and configures the ORP to use it
#####

# Create a temporary file for openssl to put random state
export RANDFILE="$(mktemp)"

KEYSTORE_ALIAS="${ESGF_KEYSTORE_ALIAS:-esgf-self}"
KEYSTORE_FILE="$ESGF_HOME/tomcat/hostcert.p12"
# Generate a random keystore password for this container run
KEYSTORE_PASSWORD="$(openssl rand -hex 32)"

# Create the keystore
echo "[info] Creating PKCS12 bundle for host certificate and key"
mkdir -p "$(dirname "$ESGF_KEYSTORE_FILE")"
openssl pkcs12 -export \
    -name "$KEYSTORE_ALIAS" \
    -out "$KEYSTORE_FILE" \
    -in "$ESGF_HOSTCERT_DIR/tls.crt" \
    -inkey "$ESGF_HOSTCERT_DIR/tls.key" \
    -password "pass:$KEYSTORE_PASSWORD"

rm -rf "$RANDFILE"
unset RANDFILE

# Configure the ORP to use it
echo "[info] Configuring ORP to use PKCS12 bundle"
CATALINA_EXTRA_OPTS="-Desg.orp.keystore.file=$KEYSTORE_FILE"
CATALINA_EXTRA_OPTS="$CATALINA_EXTRA_OPTS -Desg.orp.keystore.alias=$KEYSTORE_ALIAS"
CATALINA_EXTRA_OPTS="$CATALINA_EXTRA_OPTS -Desg.orp.keystore.password=$KEYSTORE_PASSWORD"
export CATALINA_EXTRA_OPTS
