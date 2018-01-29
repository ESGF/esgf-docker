#!/bin/bash

set -eo pipefail

: ${ESGF_SOLR_PUBLISH_URL:="$ESGF_SOLR_INTERNAL_URL"}
: ${ESGF_SOLR_QUERY_URL:="$ESGF_SOLR_INTERNAL_URL"}

[ -z "$ESGF_SOLR_PUBLISH_URL" ] && {
    echo "ESGF_SOLR_PUBLISH_URL or ESGF_SOLR_INTERNAL_URL must be specified" 1>&2
    exit 1
}
[ -z "$ESGF_SOLR_QUERY_URL" ] && {
    echo "ESGF_SOLR_QUERY_URL or ESGF_SOLR_INTERNAL_URL must be specified" 1>&2
    exit 1
}
[ -z "$ESGF_SOLR_EXTERNAL_URL" ] && {
    echo "ESGF_SOLR_EXTERNAL_URL must be specified" 1>&2
    exit 1
}
ESGF_SOLR_HOSTNAME="${ESGF_SOLR_EXTERNAL_URL##http*://}"
[ -z "$ESGF_ORP_URL" ] && {
    echo "ESGF_ORP_URL must be specified" 1>&2
    exit 1
}

export ESGF_SOLR_PUBLISH_URL ESGF_SOLR_QUERY_URL ESGF_ORP_URL ESGF_SOLR_HOSTNAME

echo "[INFO] Using ESGF_SOLR_PUBLISH_URL: $ESGF_SOLR_PUBLISH_URL"
echo "[INFO] Using ESGF_SOLR_QUERY_URL: $ESGF_SOLR_QUERY_URL"
echo "[INFO] Using ESGF_ORP_URL: $ESGF_ORP_URL"

#####
## Ensure that the required collections/cores exist in Solr
##
## Use the publish URL as that is the master in situtation where there is a master/slave config
#####
INDEXES=("datasets"  "files"  "aggregations")
solr_mode=$(curl -fsSL $ESGF_SOLR_PUBLISH_URL/solr/admin/info/system?wt=json | jq -r ".mode")
if [ "$solr_mode" = "solrcloud" ]; then
    echo "[INFO] Creating Solr collections"
    # Get the list of existing collections
    existing=( $(curl -fsSL "$ESGF_SOLR_PUBLISH_URL/solr/admin/collections?action=LIST&wt=json" | jq -r ".collections | join(\" \")") )
    # SolrCloud mode - create collections
    for name in "${INDEXES[@]}"; do
        # If the name is already in the list of collections, don't create it
        if echo "${existing[@]}" | grep -q "$name"; then
            echo "[INFO]   Collection '$name' already exists - skipping"
        else
            curl -o /dev/null -fsSL "$ESGF_SOLR_PUBLISH_URL/solr/admin/collections?action=CREATE&name=${name}&collection.configName=esgf&numShards=${ESGF_SOLR_INDEX_NSHARDS:-1}"
            echo "[INFO]   Created collection '$name'"
        fi
    done
else
    echo "[ERROR] Only SolrCloud mode is supported for now"
    exit 1
#    echo "[INFO] Creating Solr cores"
    # Standalone mode - create cores
#    for name in "${INDEXES[@]}"; do
#        curl -fsS "$ESGF_SOLR_PUBLISH_URL/solr/admin/cores?action=CREATE&name=${name}&configSet=esgf"
#    done
fi

#####
## Interpolate config files with values from the environment where required
##
## If the actual files already exist, i.e. because they have been mounted
## in, use them in preference
#####
echo "[INFO] Interpolating configuration files"

ESGF_PROPS_FILE="/esg/config/esgf.properties"
[ -f "$ESGF_PROPS_FILE" ] || envsubst < "$ESGF_PROPS_FILE.template" > "$ESGF_PROPS_FILE"

ESGF_SHARDS_FILE="/esg/config/esgf_shards_static.xml"
[ -f "$ESGF_SHARDS_FILE" ] || envsubst < "$ESGF_SHARDS_FILE.template" > "$ESGF_SHARDS_FILE"
