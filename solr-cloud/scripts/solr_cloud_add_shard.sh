#!/bin/sh
# Script to add a new shard to replicate a remote index node, 
# for all ESGF collections (datsets, files, aggregations)
# This script MUST be executed onto the node that runs the Solr with the embedded ZooKeeper.
# The shard replicas will be spread across all currently running Solr instances, on all nodes.
#
# Usage: ./solr_cloud_add_shard.sh <index_node_fqdn>

collections=('datasets' 'files' 'aggregations')
shard=$1
if [ "$shard" = "" ]; then
  echo "Invalid <index_node_fqdn> supplied"
  exit
fi

for ((i=0; i < ${#collections[@]}; i++)); do

  collection=${collections[i]}
  echo "Creating shard: $shard for collection: $collection"
  curl "http://localhost:8983/solr/admin/collections?action=CREATESHARD&shard=${shard}&collection=${collection}"

done

