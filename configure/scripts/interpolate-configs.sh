#!/bin/bash

set -eo pipefail

function info { echo "[INFO] $1"; }
function error { echo "[ERROR] $1" 1>&2; exit 1; }

#####
## This script looks for all files in /esg/config with a .template suffix and
## runs them through envsubst to replace environment variables to create the
## file without the .template suffix
##
## If the file already exists, this process is skipped for that file
#####
info "Interpolating configuration files"

###
# First, check that required configs exist and set some defaults
###
# Passwords
#   In production, these would be mounted in as files from secrets, so these
#   defaults would never take effect
#   If the files already exist, populate the variables from them instead of the
#   other way round
if [ -f "/esg/config/.esgf_pass" ]; then
    ESGF_ROOTADMIN_PASSWORD="$(cat /esg/config/.esgf_pass)"
else
    : ${ESGF_ROOTADMIN_PASSWORD:="changeit"}
fi
if [ -f "/esg/config/.esg_pg_pass" ]; then
    ESGF_DATABASE_PASSWORD="$(cat /esg/config/.esg_pg_pass)"
else
    : ${ESGF_DATABASE_PASSWORD:="changeit"}
fi
if [ -f "/esg/config/.esg_pg_publisher_pass" ]; then
    ESGF_PUBLISHER_DATABASE_PASSWORD="$(cat /esg/config/.esg_pg_publisher_pass)"
else
    : ${ESGF_PUBLISHER_DATABASE_PASSWORD:="changeit"}
fi
# Database settings
[ -z "$ESGF_DATABASE_HOST" ] && error "ESGF_DATABASE_HOST must be set"
: ${ESGF_DATABASE_NAME:="esgcet"}
: ${ESGF_DATABASE_PORT:="5432"}
: ${ESGF_DATABASE_USER:="dbsuper"}
# Hostnames and URLs for components
[ -z "$ESGF_HOSTNAME" ] && error "ESGF_HOSTNAME must be set"
: ${ESGF_PEER_GROUP:="esgf-test"}
: ${ESGF_INDEX_NODE_HOSTNAME:="$ESGF_HOSTNAME"}
: ${ESGF_INDEX_NODE_URL:="https://${ESGF_INDEX_NODE_HOSTNAME}"}
: ${ESGF_IDP_HOSTNAME:="$ESGF_HOSTNAME"}
: ${ESGF_IDP_URL:="https://${ESGF_IDP_HOSTNAME}"}
: ${ESGF_ORP_HOSTNAME:="$ESGF_HOSTNAME"}
: ${ESGF_ORP_URL:="https://${ESGF_ORP_HOSTNAME}"}
: ${ESGF_SOLR_HOSTNAME:="$ESGF_HOSTNAME"}
: ${ESGF_SOLR_INTERNAL_URL:="http://${ESGF_SOLR_HOSTNAME}"}
: ${ESGF_SOLR_QUERY_URL:="$ESGF_SOLR_INTERNAL_URL"}
: ${ESGF_SOLR_PUBLISH_URL:="$ESGF_SOLR_INTERNAL_URL"}
: ${ESGF_SLCS_HOSTNAME:="$ESGF_HOSTNAME"}
: ${ESGF_SLCS_PREFIX:="/esgf-slcs"}
: ${ESGF_SLCS_URL:="https://${ESGF_SLCS_HOSTNAME}${ESGF_SLCS_PREFIX}"}

# Make sure we export all the required configs
export ESGF_ROOTADMIN_PASSWORD \
       ESGF_DATABASE_PASSWORD \
       ESGF_PUBLISHER_DATABASE_PASSWORD \
       ESGF_DATABASE_HOST \
       ESGF_DATABASE_NAME \
       ESGF_DATABASE_PORT \
       ESGF_DATABASE_USER \
       ESGF_HOSTNAME \
       ESGF_PEER_GROUP \
       ESGF_INDEX_NODE_HOSTNAME \
       ESGF_INDEX_NODE_URL \
       ESGF_IDP_HOSTNAME \
       ESGF_IDP_URL \
       ESGF_ORP_URL \
       ESGF_SOLR_HOSTNAME \
       ESGF_SOLR_QUERY_URL \
       ESGF_SOLR_PUBLISH_URL \
       ESGF_SLCS_URL

info "Using environment:"
env | grep "ESGF_" | grep -v "_PASSWORD"


###
# Interpolate each file ending in .template unless the actual file already exists
###
for src in $(find /esg/config -type f -name '*.template'); do
    dest="${src%".template"}"
    [ -f "$dest" ] || envsubst < "$src" > "$dest"
done
