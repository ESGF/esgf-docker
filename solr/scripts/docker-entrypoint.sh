#!/bin/bash
# script to start one Solr instance per shard
# and keep the Docker container running

cd $SOLR_INSTALL_DIR/bin
export SOLR_INCLUDE=${SOLR_HOME}/solr.in.sh
./solr start -d $SOLR_INSTALL_DIR/server -s $SOLR_HOME/master-8984 -p 8984 -a '-Denable.master=true'
./solr start -d $SOLR_INSTALL_DIR/server -s $SOLR_HOME/slave-8983 -p 8983 -a '-Denable.slave=true'

tail -f $SOLR_INSTALL_DIR/server/logs/solr.log
