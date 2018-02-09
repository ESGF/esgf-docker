#!/bin/bash

set -eo pipefail

[ -z "$ESGF_SOLR_PUBLISH_URL" ] && {
    echo "[ERROR] ESGF_SOLR_PUBLISH_URL or ESGF_SOLR_INTERNAL_URL must be specified" 1>&2
    exit 1
}

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
            url="$ESGF_SOLR_PUBLISH_URL/solr/admin/collections?action=CREATE"
            url="${url}&name=${name}&collection.configName=esgf"
            url="${url}&numShards=${ESGF_SOLR_COLLECTION_NUM_SHARDS:-1}"
            url="${url}&replicationFactor=${ESGF_SOLR_COLLECTION_REPLICATION_FACTOR:-1}"
            url="${url}&maxShardsPerNode=${ESGF_SOLR_COLLECTION_MAX_SHARDS_PER_NODE:-2}"
            echo "[INFO]   Using URL: $url"
            curl -o /dev/null -fsSL "$url"
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
