#!/bin/sh
# Script that uploads the ESGF schema configuration to the Solr Cloud ZooKeeper,
# and creates a set of 3 collections, each with 3 initial shards.
#
# Must be run only once before any data collection is created.
# All necessary Solr instances must be running prior to executing this script.

# upload configuration to ZooKeeper
$SOLR_CLOUD_HOME/solr/server/scripts/cloud-scripts/zkcli.sh \
	-zkhost localhost:9983 \
	-cmd upconfig -confdir $SOLR_CLOUD_HOME/node8983/solr/conf -confname esgf_config

# create 3 collection: datasets, files, aggregations
# for each collection, create an initial set of 3 shards matching 3 specific index nodes
# REQUIREMENT: num_shards * replication_factor <= num_nodes * max_shard_per_node
collections=('datasets' 'files' 'aggregations')
shards="esgf-node.jpl.nasa.gov,pcmdi.llnl.gov,esgf-data.dkrz.de"

for ((i=0; i < ${#collections[@]}; i++)); do
  collection=${collections[i]}

  echo "Creating collection: $collection"
  curl "http://localhost:8983/solr/admin/collections?action=CREATE&name=${collection}&replicationFactor=2&maxShardsPerNode=2&collection.configName=esgf_config&router.name=implicit&router.field=index_node&shards=${shards}"

done
