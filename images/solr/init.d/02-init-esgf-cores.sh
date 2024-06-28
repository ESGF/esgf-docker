#!/bin/bash

#####
## Initialise ESGF cores
#####

set -eo pipefail

ESGF_CORES=( "datasets"  "files"  "aggregations" )
for corename in "${ESGF_CORES[@]}"; do
    coredir="$SOLR_HOME/$corename"
    # Create the core directory if it doesn't already exist
    if [ ! -d "$coredir" ]; then
        mkdir -p "$coredir"
    fi
    # Replace the core configuration with the most recent version
    cp "/esg/solr-home/$corename/core.properties" "$coredir/core.properties"
    rm -rf "$coredir/conf"
    cp -r /esg/core-template/conf "$coredir/conf"
done
