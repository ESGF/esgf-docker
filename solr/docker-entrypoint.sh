#!/bin/bash

set -eo pipefail

# Make sure SOLR_HOME is set and has the correct permissions
[ -z "$SOLR_HOME" ] && { echo "[ERROR] SOLR_HOME must be set" 1>&2 ; exit 1; }
chown -R "$SOLR_USER":"$SOLR_GROUP" "$SOLR_HOME"
chmod -R 700 "$SOLR_HOME"

# Opt in to initialisation of SOLR_HOME on first use
export INIT_SOLR_HOME="yes"

if [ -n "$ZOOKEEPER_HOST" ]; then
    : ${ZOOKEEPER_PORT:="2181"}
    # Try and connect to zookeeper, bailing if it is not available
    if ! (echo stat | nc "$ZOOKEEPER_HOST" "$ZOOKEEPER_PORT" | grep Zxid); then
        echo "[ERROR] Failed to connect to $ZOOKEEPER_HOST" 1>&2
        exit 1
    fi

    # Upload the ESGF config to zookeeper
    /opt/solr/server/scripts/cloud-scripts/zkcli.sh \
        -zkhost "${ZOOKEEPER_HOST}:${ZOOKEEPER_PORT}" \
        -cmd upconfig \
        -confdir /esg/solr-config \
        -confname esgf
    echo "[INFO] Uploaded ESGF configset to zookeeper"
fi

# Run the given command
echo "[INFO] Running '$@'"
exec gosu "$SOLR_USER" /opt/docker-solr/scripts/docker-entrypoint.sh "$@"
