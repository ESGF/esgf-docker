#!/bin/bash

#####
## This script sets up the required cores before deferring to the standard entrypoint
#####

set -ex

# Set up data directory
: ${ESGF_SOLR_DATA_DIR:=/esg/solr-data}
mkdir -p "$ESGF_SOLR_DATA_DIR"

# Set up the cores
: ${SOLR_HOME:=/opt/solr/server/solr}
corenames=("datasets"  "files"  "aggregations")
for corename in "${corenames[@]}"; do
    # Create the core.properties
    coredir="$SOLR_HOME/$corename"
    mkdir -p "$coredir"
    cat <<EOF > "$coredir/core.properties"
name=$corename
configSet=esgf
EOF
    # Create the core data directory if required
    mkdir -p "$ESGF_SOLR_DATA_DIR/$corename"
    # Link it from the core directory
    ln -sf "$ESGF_SOLR_DATA_DIR/$corename" "$coredir/data"
done

# Transfer ownership of everything we just created to the solr user
chown -R "$SOLR_USER":"$SOLR_GROUP" "$SOLR_HOME"
chown -R "$SOLR_USER":"$SOLR_GROUP" "$ESGF_SOLR_DATA_DIR"

exec gosu "$SOLR_USER" /opt/docker-solr/scripts/docker-entrypoint.sh "$@"
