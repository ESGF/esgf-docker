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
: ${ESGF_PROXY_SSL_CLIENT_TRUSTED_CERTS:="/esg/certificates/esg-trust-bundle.pem"}

# Extract the nameserver from /etc/resolv.conf for the Nginx resolver statement
ESGF_RESOLVER="$(grep nameserver /etc/resolv.conf | awk '{ print $2; }')"

# Make sure the variables we need are exported
export ESGF_HOSTNAME \
       ESGF_SOLR_UPSTREAM \
       ESGF_INDEX_NODE_UPSTREAM \
       ESGF_TDS_UPSTREAM \
       ESGF_COG_UPSTREAM \
       ESGF_ORP_UPSTREAM \
       ESGF_IDP_UPSTREAM \
       ESGF_SLCS_UPSTREAM \
       ESGF_AUTH_UPSTREAM \
       ESGF_PROXY_SSL_CERT_FILE \
       ESGF_PROXY_SSL_KEY_FILE \
       ESGF_PROXY_SSL_CLIENT_TRUSTED_CERTS \
       ESGF_RESOLVER

# Use envsubst to replace environment variables in the Nginx config
# Because Nginx variables look like environment variables, we need to specify
# the variables we want to replace
tmpfile="$(mktemp)"
cp /etc/nginx/conf.d/esgf.conf "$tmpfile"
envsubst "$(printf '${%s} ' $(bash -c "compgen -A variable" | grep "ESGF_"))" < "$tmpfile" > /etc/nginx/conf.d/esgf.conf

# Run the given command, usually nginx -g daemon off;
exec "$@"
