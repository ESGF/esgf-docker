#!/bin/bash

function error {
    echo "[ERROR] $1" 1>&2 ; exit 1
}

# Verify that the required environment variables are present
[ -z "$ESGF_HOSTNAME" ] && error "ESGF_HOSTNAME must be set"
#[ -z "$ESGF_SOLR_INTERNAL_URL" ] && error "ESGF_SOLR_INTERNAL_URL must be set"
[ -z "$ESGF_INDEX_NODE_INTERNAL_URL" ] && error "ESGF_INDEX_NODE_INTERNAL_URL must be set"
[ -z "$ESGF_TDS_INTERNAL_URL" ] && error "ESGF_TDS_INTERNAL_URL must be set"
[ -z "$ESGF_ORP_INTERNAL_URL" ] && error "ESGF_ORP_INTERNAL_URL must be set"
[ -z "$ESGF_IDP_INTERNAL_URL" ] && error "ESGF_IDP_INTERNAL_URL must be set"
[ -z "$ESGF_SLCS_INTERNAL_URL" ] && error "ESGF_SLCS_INTERNAL_URL must be set"
[ -z "$ESGF_AUTH_INTERNAL_URL" ] && error "ESGF_AUTH_INTERNAL_URL must be set"
[ -z "$ESGF_COG_INTERNAL_URL" ] && error "ESGF_AUTH_INTERNAL_URL must be set"
: ${ESGF_PROXY_SSL_CERT_FILE:="/etc/nginx/ssl/${ESGF_HOSTNAME}.crt"}
: ${ESGF_PROXY_SSL_KEY_FILE:="/etc/nginx/ssl/${ESGF_HOSTNAME}.key"}
# Re-export these in case they weren't specified in the stack file
export ESGF_PROXY_SSL_CERT_FILE ESGF_PROXY_SSL_KEY_FILE

# Use envsubst to replace only variables with the ESGF_ prefix in the Nginx config
tmpfile="$(mktemp)"
cp /etc/nginx/conf.d/esgf.conf $tmpfile
envsubst "`printf '${%s} ' $(bash -c "compgen -A variable" | grep "ESGF_")`" < $tmpfile > /etc/nginx/conf.d/esgf.conf

# Run the given command, usually nginx -g daemon off;
exec "$@"
