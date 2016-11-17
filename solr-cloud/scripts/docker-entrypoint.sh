#!/bin/bash
# script to start all Solr instances om this node
# and keep the Docker container running

# optional FQDN for ZooKeeper host
zkhost=$1

/usr/local/bin/solr_cloud_start.sh $zkhost

tail -f $SOLR_CLOUD_HOME/solr/server/logs/solr.log
