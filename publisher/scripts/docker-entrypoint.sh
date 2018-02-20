#!/bin/bash

set -eo pipefail

function info { echo "[INFO] $1"; }
function error { echo "[ERROR] $1" 1>&2; exit 1; }

#####
## This script sets up the publisher container before executing the given command
##
## This includes interpolating configuration files in /esg/config/esgcet with
## values from the environment, running "esginitialize -c" and fetching a
## certificate from the SLCS for use with the publish.
#####

# Make sure the trusted certificates have been updated
info "Updating trusted certificates"
# Split esg-trusted-bundle.pem into separate certificates in the ca-certificates directory
# used by update-ca-certificates
# This is required because keytool only imports the first cachain from each file
pushd /usr/local/share/ca-certificates
csplit -z -f 'cert' -b '%03d.crt' /esg/certificates/esg-trust-bundle.pem "/END CERTIFICATE/1" "{*}"
popd
update-ca-certificates
# Make sure Python uses the correct trust bundle
export SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt

info "Configuring environment"
###
#Check that required variables exist and set some defaults
###
# Database settings
[ -z "$ESGF_DATABASE_HOST" ] && error "ESGF_DATABASE_HOST must be set"
: ${ESGF_DATABASE_NAME:="esgcet"}
: ${ESGF_DATABASE_PORT:="5432"}
: ${ESGF_DATABASE_USER:="dbsuper"}
if [ -z "$ESGF_DATABASE_PASSWORD" ]; then
    [ -z "$ESGF_DATABASE_PASSWORD_FILE" ] && \
        error "ESGF_DATABASE_PASSWORD or ESGF_DATABASE_PASSWORD_FILE must be set"
    [ -f "$ESGF_DATABASE_PASSWORD_FILE" ] || \
        error "ESGF_DATABASE_PASSWORD_FILE does not exist"
    ESGF_DATABASE_PASSWORD="$(cat "$ESGF_DATABASE_PASSWORD_FILE")"
fi
# Hostnames and URLs for components
: ${ESGF_INDEX_NODE_HOSTNAME:="$ESGF_HOSTNAME"}
if [ -z "$ESGF_HESSIAN_URL" ]; then
    [ -z "$ESGF_INDEX_NODE_HOSTNAME" ] && error "ESGF_HESSIAN_URL, ESGF_INDEX_NODE_HOSTNAME or ESGF_HOSTNAME must be set"
    ESGF_HESSIAN_URL="https://${ESGF_INDEX_NODE_HOSTNAME}/esg-search/remote/secure/client-cert/hessian/publishingService"
fi
if [ -z "$ESGF_HESSIAN_METADATA_URL" ]; then
    [ -z "$ESGF_HOSTNAME" ] && error "ESGF_HESSIAN_METADATA_URL or ESGF_HOSTNAME must be set"
    ESGF_HESSIAN_METADATA_URL="http://${ESGF_HOSTNAME}/esgcet/remote/hessian/guest/remoteMetadataService"
fi
: ${ESGF_TDS_HOSTNAME:="$ESGF_HOSTNAME"}
if [ -z "$ESGF_TDS_CATALOG_URL" ]; then
    [ -z "$ESGF_TDS_HOSTNAME" ] && error "ESGF_TDS_CATALOG_URL, ESGF_TDS_HOSTNAME or ESGF_HOSTNAME must be set"
    ESGF_TDS_CATALOG_URL="http://${ESGF_TDS_HOSTNAME}/thredds/catalog/esgcet"
fi
if [ -z "$ESGF_TDS_REINIT_URL" ]; then
    [ -z "$ESGF_TDS_HOSTNAME" ] && error "ESGF_TDS_REINIT_URL, ESGF_TDS_HOSTNAME or ESGF_HOSTNAME must be set"
    ESGF_TDS_REINIT_URL="https://${ESGF_TDS_HOSTNAME}/thredds/admin/debug?Catalogs/recheck"
fi
if [ -z "$ESGF_TDS_REINIT_ERROR_URL" ]; then
    [ -z "$ESGF_TDS_HOSTNAME" ] && error "ESGF_TDS_REINIT_ERROR_URL, ESGF_TDS_HOSTNAME or ESGF_HOSTNAME must be set"
    ESGF_TDS_REINIT_ERROR_URL="https://${ESGF_TDS_HOSTNAME}/thredds/admin/content/logs/catalogInit.log"
fi
[ -z "$ESGF_TDS_USERNAME" ] && error "ESGF_TDS_USERNAME must be set"
if [ -z "$ESGF_TDS_PASSWORD" ]; then
    [ -z "$ESGF_TDS_PASSWORD_FILE" ] && \
        error "ESGF_TDS_PASSWORD or ESGF_TDS_PASSWORD_FILE must be set"
    [ -f "$ESGF_TDS_PASSWORD_FILE" ] || \
        error "ESGF_TDS_PASSWORD_FILE does not exist"
    ESGF_TDS_PASSWORD="$(cat "$ESGF_TDS_PASSWORD_FILE")"
fi

# Make sure we export all the required configs
export ESGF_DATABASE_HOST \
       ESGF_DATABASE_NAME \
       ESGF_DATABASE_PORT \
       ESGF_DATABASE_USER \
       ESGF_DATABASE_PASSWORD \
       ESGF_HESSIAN_URL \
       ESGF_HESSIAN_METADATA_URL \
       ESGF_TDS_CATALOG_URL \
       ESGF_TDS_REINIT_URL \
       ESGF_TDS_REINIT_ERROR_URL \
       ESGF_TDS_USERNAME \
       ESGF_TDS_PASSWORD

info "Using environment:"
env | grep "ESGF_" | grep -v "_PASSWORD"


###
# Interpolate each file ending in .template unless the actual file already exists
###
info "Interpolating config files"
for src in $(find /esg/config/esgcet -type f -name '*.template'); do
    dest="${src%".template"}"
    [ -f "$dest" ] || envsubst < "$src" > "$dest"
done

# Initialise the THREDDS content
info "Ensuring THREDDS content root exists"
mkdir -p /esg/content/thredds/esgcet
# Sync the skeleton to the actual content directory
# The --ignore-existing flag should make sure any existing files are not overwritten
info "Copying any missing THREDDS configuration files"
rsync -a --ignore-existing /esg/content/thredds-skel/ /esg/content/thredds

# Run esginitialize
info "Running esginitialize -c"
esginitialize -c

info "Intialisation complete"

# Execute the specified command
exec "$@"
