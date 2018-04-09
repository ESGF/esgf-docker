#!/bin/bash

set -eo pipefail

# Create the cores for ESGF
ESGF_CORES=( "datasets"  "files"  "aggregations" )
for corename in "${ESGF_CORES[@]}"; do
    coredir="${SOLR_HOME:-/opt/solr/server/solr}/$corename"
    # Create the core directory if it doesn't already exist
    if [ ! -f "$coredir/core.properties" ]; then
        mkdir -p "$coredir"
        touch "$coredir/core.properties"
    fi
    # Replace the core configuration with the most recent version
    rm -rf "$coredir/conf"
    cp -r /esg/solr-core-config/conf "$coredir/conf"
done
