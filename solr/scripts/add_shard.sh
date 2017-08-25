#!/bin/sh
# shell script to add a new Solr shard
#
# example invocation: add_shard.sh master 8984
# example invocation: add_shard.sh esgf-node.llnl.gov 8985
#
# note: this script is idempotent: it can be run multiple times without affecting the shard installation

# command line arguments
shard_name=$1
shard_port=$2
shard="$1-$2"

# create index directory /esg/solr-index/<host>-<port>/
mkdir -p /esg/solr-index/${shard}
chown -R solr:solr /esg/solr-index/${shard}

# create solr-home directory /usr/local/solr-home/<host>-<port>/
if [ ! -d "$SOLR_HOME/${shard}" ]; then
  echo "Installing Solr shard: $shard"

  cp -R /usr/local/src/solr-home $SOLR_HOME/${shard}
  rm -rf $SOLR_HOME/${shard}/mycore

  # configure each core
  cores=("datasets"  "files"  "aggregations")
  for core in "${cores[@]}"
  do
    echo "Installing Solr core: $core"
    cp -R /usr/local/src/solr-home/mycore $SOLR_HOME/${shard}/${core}
    sed -i 's/@mycore@/'${core}'/g' $SOLR_HOME/$shard/$core/core.properties && \
    sed -i 's/@solr_config_type@-@solr_server_port@/'${shard}'/g' $SOLR_HOME/${shard}/${core}/core.properties
    sed -i '/masterUrl/ s/localhost:8984/'${shard_name}':'${shard_port}'/' $SOLR_HOME/${shard}/${core}/conf/solrconfig.xml
  done
  chown -R solr:solr $SOLR_HOME/${shard}

fi

# create supervisor configuration for starting the service
supervisord_config="/etc/supervisor/conf.d/supervisord.solr_${shard_name}_${shard_port}.conf"
if [ ! -f "${supervisord_config}" ]; then
  echo "Creating supervisord configuration: $supervisord_config"

  cp /usr/local/src/supervisord.solr_HOST_PORT.conf-TEMPLATE $supervisord_config
  sed -i 's/@host@/'${shard_name}'/g' $supervisord_config
  sed -i 's/@port@/'${shard_port}'/g' $supervisord_config
  if [ $shard_name == 'master' ]; then
    sed -i 's/@master_slave@/-Denable.master=true/g' $supervisord_config
  elif [ $shard_name == 'slave' ]; then
    sed -i 's/@master_slave@/-Denable.slave=true -Denable.master=true/g' $supervisord_config
  else
    sed -i 's/@master_slave@/-Denable.slave=true -Denable.master=true/g' $supervisord_config
  fi

  # add this program to the solr group
  if grep -q ${shard_name} /etc/supervisor/conf.d/supervisord.solr.conf;
   then
     echo "$shard already part of supervisor group 'solr'"
   else
     echo "Adding $shard to supervisor group 'solr'"
     sed -i '/^programs=/ s/$/,'${shard_name}'_'${shard_port}'/' /etc/supervisor/conf.d/supervisord.solr.conf
  fi

fi

# add shard to list queried by ESGF search application (unless shard = 'master' or 'slave')
if ! [[ $shard_name == 'master' || $shard_name == 'slave' ]]; then
  shards_file="/esg/config/esgf_shards_static.xml"
  if ! grep -q ${shard_port} ${shards_file} ; then
    echo "Adding shard to ${shards_file}"
    sed -i 's/<\/shards>/    <value>localhost:'${shard_port}'\/solr<\/value>\n<\/shards>/g' ${shards_file}
  fi
fi
