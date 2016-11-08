#!/bin/sh
# example invocation: add_shard.sh master 8984

# command line arguments

shard_name=$1
shard_port=$2
shard="$1-$2"

# create solr-home directory
echo "Installing Solr shard: $shard"
cp -R /usr/local/src/solr-home $SOLR_HOME/${shard}
rm -rf $SOLR_HOME/${shard}/mycore

# create cores
cores=("datasets"  "files"  "aggregations")
for core in "${cores[@]}"
do
  echo "Installing Solr core: $core"
  cp -R /usr/local/src/solr-home/mycore $SOLR_HOME/${shard}/${core}
  sed -i 's/@mycore@/'${core}'/g' $SOLR_HOME/$shard/$core/core.properties && \
  sed -i 's/@solr_config_type@-@solr_server_port@/'${shard}'/g' $SOLR_HOME/${shard}/${core}/core.properties
done
