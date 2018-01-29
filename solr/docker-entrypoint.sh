#!/bin/bash

#####
## This script sets up the required cores before deferring to the standard entrypoint
#####

set -e

# Make sure SOLR_HOME is set and has the correct permissions
[ -z "$SOLR_HOME" ] && { echo "[ERROR] SOLR_HOME must be set" 1>&2 ; exit 1; }
chown -R "$SOLR_USER":"$SOLR_GROUP" "$SOLR_HOME"
chmod -R 700 "$SOLR_HOME"

# Opt in to initialisation of SOLR_HOME on first use
export INIT_SOLR_HOME="yes"

if [ -n "$ZOOKEEPER_HOST" ]; then
    : ${ZOOKEEPER_PORT:="2181"}
    # Wait up to 5 minutes for zookeeper to become available
    WAIT=5
    TRIES=60
    connected=0
    for i in $(seq 1 $TRIES); do
        if echo stat | nc "$ZOOKEEPER_HOST" "$ZOOKEEPER_PORT" | grep Zxid; then
            connected=1
            break
        fi
        echo "[INFO] Waiting for connection to $ZOOKEEPER_HOST..."
        sleep $WAIT
    done
    if [ "$connected" -eq "1" ]; then
        echo "[INFO] Connected to $ZOOKEEPER_HOST"
    else
        echo "[ERROR] Failed to connect to $ZOOKEEPER_HOST" 1>&2
        exit 1
    fi

    # Upload the ESGF configset to zookeeper
    /opt/solr/server/scripts/cloud-scripts/zkcli.sh \
        -zkhost esgf-zookeeper:2181 \
        -cmd upconfig \
        -confdir /esg/solr-configset \
        -confname esgf
fi

echo "$@"

# Run the given command
exec gosu "$SOLR_USER" /opt/docker-solr/scripts/docker-entrypoint.sh "$@"
