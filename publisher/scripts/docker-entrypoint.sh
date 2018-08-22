#!/bin/bash

set -euo pipefail

. /esg/bin/functions.sh

#####
## This script sets up the publisher container before executing the given command
##
## This includes interpolating configuration files in /esg/config/esgcet with
## values from the environment and running "esginitialize -c"
#####

# Make sure the trusted certificates have been updated
info "Updating trusted certificates"
# Combine the trusted certificates into a single bundle and make sure Python and curl use it
cat /etc/ssl/certs/ca-certificates.crt > /esg/config/esgcet/trust-bundle.pem
cat /esg/certificates/esg-trust-bundle.pem >> /esg/config/esgcet/trust-bundle.pem
export SSL_CERT_FILE=/esg/config/esgcet/trust-bundle.pem

# Compose the database URL
# Using gomplate here allows us to benefit from _FILE fallback
ESGF_DATABASE_PASSWORD="$(/esg/bin/gomplate -i '{{ getenv "ESGF_DATABASE_PASSWORD" }}')"
export DATABASE_URL="postgresql://${ESGF_DATABASE_USER}:${ESGF_DATABASE_PASSWORD}@${ESGF_DATABASE_HOST}:${ESGF_DATABASE_PORT}/${ESGF_DATABASE_NAME}"

###
# Build the configuration directory
###
/esg/bin/build-config.sh /esg/config/esgcet

# Initialise the schema migration
info "Enabling schema versioning"
if python -m esgcet.schema_migration.manage db_version "${DATABASE_URL}" 1>/dev/null 2>&1; then
    info "  Schema versioning already enabled - skipping"
else
    python -m esgcet.schema_migration.manage version_control "${DATABASE_URL}"
fi

# Run esginitialize
info "Running esginitialize -c"
esginitialize -c

info "Intialisation complete"

# Execute the specified command
exec "$@"
