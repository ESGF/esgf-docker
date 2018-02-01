#!/bin/bash

function error {
    echo "[ERROR] $1" 1>&2 ; exit 1
}

# Verify that the required environment variables are present
[ -z "$ESGF_HOSTNAME" ] && error "ESGF_HOSTNAME must be set"
[ -z "$ESGF_SOLR_UPSTREAM" ] && error "ESGF_SOLR_UPSTREAM must be set"
[ -z "$ESGF_INDEX_NODE_UPSTREAM" ] && error "ESGF_INDEX_NODE_UPSTREAM must be set"
[ -z "$ESGF_TDS_UPSTREAM" ] && error "ESGF_TDS_UPSTREAM must be set"
[ -z "$ESGF_COG_UPSTREAM" ] && error "ESGF_COG_UPSTREAM must be set"
[ -z "$ESGF_ORP_UPSTREAM" ] && error "ESGF_ORP_UPSTREAM must be set"
[ -z "$ESGF_IDP_UPSTREAM" ] && error "ESGF_IDP_UPSTREAM must be set"
[ -z "$ESGF_SLCS_UPSTREAM" ] && error "ESGF_SLCS_UPSTREAM must be set"
[ -z "$ESGF_AUTH_UPSTREAM" ] && error "ESGF_AUTH_UPSTREAM must be set"
: ${ESGF_PROXY_SSL_CERT_FILE:="/etc/nginx/ssl/hostcert.crt"}
: ${ESGF_PROXY_SSL_KEY_FILE:="/etc/nginx/ssl/hostcert.key"}
# Re-export these in case they weren't specified in the stack file
export ESGF_PROXY_SSL_CERT_FILE ESGF_PROXY_SSL_KEY_FILE

# Use envsubst to replace environment variables in the Nginx config
# Because Nginx variables look like environment variables, we need to specify
# the variables we want to replace
tmpfile="$(mktemp)"
cp /etc/nginx/conf.d/esgf.conf "$tmpfile"
envsubst "$(printf '${%s} ' $(bash -c "compgen -A variable" | grep "ESGF_"))" < "$tmpfile" > /etc/nginx/conf.d/esgf.conf

# Run the given command, usually nginx -g daemon off;
exec "$@"
