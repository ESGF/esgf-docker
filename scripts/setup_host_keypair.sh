#!/bin/bash

set -eo pipefail

function error { echo "[ERROR] $1" 1>&2 ; exit 1; }

#####
## This script creates a new self-signed keypair for the node
#####
[ -z "$ESGF_CONFIG" ] && error "ESGF_CONFIG must be set"
# Strip any trailing slashes
ESGF_CONFIG="${ESGF_CONFIG%/}"
[ -z "$ESGF_HOSTNAME" ] && error "ESGF_HOSTNAME must be set"
# Set a default value for the subject
: ${ESGF_HOSTCERT_SUBJECT:="/O=esgf/CN=$ESGF_HOSTNAME"}

echo "[INFO] Using ESGF_CONFIG = $ESGF_CONFIG"
echo "[INFO] Using ESGF_HOSTNAME = $ESGF_HOSTNAME"

# If a hostkey already exists in the config directory, use that
# Otherwise, create a new self-signed keypair
mkdir -p "$ESGF_CONFIG/hostcert"
HOSTCERT_FILE="$ESGF_CONFIG/hostcert/${ESGF_HOSTNAME}.crt"
HOSTKEY_FILE="$ESGF_CONFIG/hostcert/${ESGF_HOSTNAME}.key"
if [ -f "$HOSTCERT_FILE" ]; then
    echo "[INFO] Using existing host keypair"
else
    echo "[INFO] Generating new host keypair with ESGF_HOSTCERT_SUBJECT = $ESGF_HOSTCERT_SUBJECT"
    # Use a docker container to avoid the need for openssl on the host
    docker run --rm \
        -v "$ESGF_CONFIG/hostcert:/hostcert" \
        centos:6 \
        openssl req -new -nodes -x509 -extensions v3_ca -days 3650  \
            -subj "$ESGF_HOSTCERT_SUBJECT" \
            -keyout /hostcert/${ESGF_HOSTNAME}.key \
            -out /hostcert/${ESGF_HOSTNAME}.crt
fi
