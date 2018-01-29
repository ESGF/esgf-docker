#!/bin/bash

set -eo pipefail

function error { echo "[ERROR] $1" 1>&2 ; exit 1; }

#####
## This script creates a new trust bundle for the ESGF certificates
#####
[ -z "$ESGF_CONFIG" ] && error "ESGF_CONFIG must be set"
# Strip any trailing slashes
ESGF_CONFIG="${ESGF_CONFIG%/}"
[ -z "$ESGF_HOSTNAME" ] && error "ESGF_HOSTNAME must be set"

echo "[INFO] Using ESGF_CONFIG = $ESGF_CONFIG"
echo "[INFO] Using ESGF_HOSTNAME = $ESGF_HOSTNAME"

echo "[INFO] Building certificate tarball"
CERT_TARBALL="$ESGF_CONFIG/esg_trusted_certificates.tar"

# If the tarball exists, unpack it, otherwise create an empty directory
if [ -f "$CERT_TARBALL" ]; then
    echo "[INFO]   Unpacking existing tarball"
    tar -xf "$ESGF_CONFIG/esg_trusted_certificates.tar" -C "$ESGF_CONFIG"
else
    echo "[INFO]   Creating empty certificate directory"
    mkdir -p "$ESGF_CONFIG/esg_trusted_certificates"
fi

# Make sure the host keypair is set up
echo "[INFO] Setting up host keypair"
"$(dirname "$(realpath "$0")")/setup_host_keypair.sh"

# If the host certificate is self-signed, add it to the trusted certificates
# Use docker to run the openssl commands to avoid requiring openssl on the host
# openssl "error 18" indicates a self-signed certificate
if docker run --rm \
       -v "$ESGF_CONFIG/hostcert:/hostcert" \
       centos:6 \
       bash -c "openssl verify /hostcert/${ESGF_HOSTNAME}.crt | grep \"error 18 \"" > /dev/null
then
    echo "[INFO] Copying self-signed host certificate"
    # Copy the certificate with its hash as the filename
    certhash="$(docker run --rm \
        -v "$ESGF_CONFIG/hostcert:/hostcert" \
        centos:6 \
        openssl x509 -hash -noout -in /hostcert/${ESGF_HOSTNAME}.crt)"
    cp "$ESGF_CONFIG/hostcert/${ESGF_HOSTNAME}.crt" "$ESGF_CONFIG/esg_trusted_certificates/${certhash}.0"
fi

# Create a new tarball
echo "[INFO] Creating new certificate tarball"
# OS X requires a special argument, otherwise it creates weird dot files
case "$OSTYPE" in
    "darwin"*) EXTRA_ARGS="--disable-copyfile" ;;
esac
tar -cf "$ESGF_CONFIG/esg_trusted_certificates.tar" -C "$ESGF_CONFIG" "$EXTRA_ARGS" esg_trusted_certificates

# Create a certificate bundle
echo "[INFO] Creating certificate bundle"
BUNDLE="$ESGF_CONFIG/esg-trusted-bundle.crt"
rm -rf "$BUNDLE"
for certfile in $(grep -lr -- "-----BEGIN CERTIFICATE-----" "$ESGF_CONFIG/esg_trusted_certificates"); do
    # Add the name of the file before the certificate
    echo "${certfile#"$ESGF_CONFIG/"}" >> "$BUNDLE"
    cat "$certfile" >> "$BUNDLE"
done
echo "" >> "$BUNDLE"

# Remove the unpacked directory
rm -rf "$ESGF_CONFIG/esg_trusted_certificates"
