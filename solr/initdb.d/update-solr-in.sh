#!/bin/bash

SOLR_IN_SH=/opt/solr/bin/solr.in.sh

# If SOLR_HEAP is set, use it to update the solr.in.sh
[ -n "$SOLR_HEAP" ] && {
    sed -i -e "s/SOLR_HEAP=\".*\"/SOLR_HEAP=\"$SOLR_HEAP\"/" "$SOLR_IN_SH"
}

# Set the master and slave flags
echo "SOLR_OPTS=\"\$SOLR_OPTS -Denable.master=true\"" >> "$SOLR_IN_SH"
[ -n "${ESGF_SOLR_ENABLE_SLAVE:-}" ] && {
    echo "SOLR_OPTS=\"\$SOLR_OPTS -Denable.slave=true\"" >> "$SOLR_IN_SH"
}

# Set the master URL property
echo "SOLR_OPTS=\"\$SOLR_OPTS -Desgf.solr.master.url=$ESGF_SOLR_MASTER_URL\"" >> "$SOLR_IN_SH"
