#!/bin/bash

set -eu

#####
# This script updates solr.in.sh with the required variables
#####

SOLR_IN_SH=/opt/solr/bin/solr.in.sh

echo "[INFO] Writing Solr configuration to ${SOLR_IN_SH}"

# If SOLR_HEAP is not set, use a 1GB heap
echo "SOLR_HEAP=\"${SOLR_HEAP:-"1g"}\"" | tee -a "$SOLR_IN_SH"

# Set Java properties
# Role is either master or replica, default replica
: ${ESGF_SOLR_ROLE:="replica"}
case "$ESGF_SOLR_ROLE" in
    "master")
        # Enable master only
        echo 'SOLR_OPTS="$SOLR_OPTS -Denable.master=true"' | tee -a "$SOLR_IN_SH"
        ;;
    "replica")
        # Replica nodes have master and slave enabled
        # They also need a master URL (required) and a replication interval (default 1 hour)
        cat <<EOF | tee -a "$SOLR_IN_SH"
SOLR_OPTS="\$SOLR_OPTS -Denable.master=true -Denable.slave=true"
SOLR_OPTS="\$SOLR_OPTS -Desgf.solr.master.url=$ESGF_SOLR_MASTER_URL"
SOLR_OPTS="\$SOLR_OPTS -Desgf.solr.replication.interval=${ESGF_SOLR_REPLICATION_INTERVAL:-"01:00:00"}"
EOF
        ;;
    *)
        echo "[ERROR] Unknown ESGF_SOLR_ROLE: $ESGF_SOLR_ROLE" 1>&2
        exit 1
esac
