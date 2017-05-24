#!/bin/bash
# Script to start one Solr instance per shard
# and keep the Docker container running

# start supervisor --> solr shards
supervisord -c /etc/supervisord.conf

# print out log file
sleep 2
tail -f $SOLR_INSTALL_DIR/server/logs/solr.log
