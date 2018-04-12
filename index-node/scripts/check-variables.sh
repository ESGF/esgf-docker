#!/bin/bash

set -eo pipefail

function error { echo "[ERROR] $1" 1>&2; exit 1; }

[ -z "$ESGF_SOLR_QUERY_URL" ] && error "ESGF_SOLR_QUERY_URL must be specified"
[ -z "$ESGF_SOLR_PUBLISH_URL" ] && error "ESGF_SOLR_PUBLISH_URL must be specified"

export ESGF_SOLR_SLAVE_HOST="${ESGF_SOLR_QUERY_URL##*://}"
