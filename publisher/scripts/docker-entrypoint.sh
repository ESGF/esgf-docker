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
# Combine the trusted certificates into a single bundle and make sure Python and curl use it
cat /etc/ssl/certs/ca-certificates.crt > /esg/config/esgcet/trust-bundle.pem
cat /esg/certificates/esg-trust-bundle.pem >> /esg/config/esgcet/trust-bundle.pem
export SSL_CERT_FILE=/esg/config/esgcet/trust-bundle.pem

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
    ESGF_HESSIAN_METADATA_URL="https://${ESGF_HOSTNAME}/esgcet/remote/hessian/guest/remoteMetadataService"
fi
: ${ESGF_TDS_HOSTNAME:="$ESGF_HOSTNAME"}
if [ -z "$ESGF_TDS_CATALOG_URL" ]; then
    [ -z "$ESGF_TDS_HOSTNAME" ] && error "ESGF_TDS_CATALOG_URL, ESGF_TDS_HOSTNAME or ESGF_HOSTNAME must be set"
    ESGF_TDS_CATALOG_URL="https://${ESGF_TDS_HOSTNAME}/thredds/catalog/esgcet"
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

# Initialise the schema migration
info "Enabling schema versioning"
DB_URL=${ESGF_DATABASE_PROTOCOL:-postgresql}://${ESGF_DATABASE_USER}:${ESGF_DATABASE_PASSWORD}@${ESGF_DATABASE_HOST}:${ESGF_DATABASE_PORT}/${ESGF_DATABASE_NAME}
if python -m esgcet.schema_migration.manage db_version "${DB_URL}" 1>/dev/null 2>&1; then
    info "  Schema versioning already enabled - skipping"
else
    python -m esgcet.schema_migration.manage version_control "${DB_URL}"
fi

# Run esginitialize
info "Running esginitialize -c"
esginitialize -c

info "Intialisation complete"

# Execute the specified command
exec "$@"
