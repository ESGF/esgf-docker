#!/usr/bin/bash

set -eo pipefail

#####
## This script creates a keystore that Java understands from the hostcert
## and configures the ORP to use it
#####

# Create a temporary file for openssl to put random state
export RANDFILE="$(mktemp)"

ESGF_KEYSTORE_ALIAS="${ESGF_KEYSTORE_ALIAS:-esgf-self}"
ESGF_KEYSTORE_FILE="${ESGF_KEYSTORE_FILE:-$ESGF_HOME/tomcat/hostcert.p12}"
# Generate a random keystore password for this container run
ESGF_KEYSTORE_PASSWORD="$(openssl rand -hex 32)"

ESGF_HOSTCERT_CERT_FILE="${ESGF_HOSTCERT_CERT_FILE:-$ESGF_HOME/hostcert/tls.crt}"
ESGF_HOSTCERT_KEY_FILE="${ESGF_HOSTCERT_KEY_FILE:-$ESGF_HOME/hostcert/tls.key}"

# Create the keystore
echo "[info] Creating PKCS12 bundle for host certificate and key"
openssl pkcs12 -export \
    -name "$ESGF_KEYSTORE_ALIAS" \
    -out "$ESGF_KEYSTORE_FILE" \
    -in "$ESGF_HOSTCERT_CERT_FILE" \
    -inkey "$ESGF_HOSTCERT_KEY_FILE" \
    -password "pass:$ESGF_KEYSTORE_PASSWORD"

rm -rf "$RANDFILE"
unset RANDFILE

# Configure the ORP to use it
echo "[info] Configuring ORP to use PKCS12 bundle"
CATALINA_EXTRA_OPTS="-Desg.orp.keystore.file=$ESGF_KEYSTORE_FILE"
CATALINA_EXTRA_OPTS="$CATALINA_EXTRA_OPTS -Desg.orp.keystore.alias=$ESGF_KEYSTORE_ALIAS"
CATALINA_EXTRA_OPTS="$CATALINA_EXTRA_OPTS -Desg.orp.keystore.password=$ESGF_KEYSTORE_PASSWORD"
export CATALINA_EXTRA_OPTS
