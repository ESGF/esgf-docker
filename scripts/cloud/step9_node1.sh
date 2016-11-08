#!/bin/sh
# node: acce-build1.dyndns.org
# Deployes ESGF data-node services

export ESGF_CONFIG=~/esgf/index-node-config
echo "Using $ESGF_CONFIG"

# start solr
docker service create --replicas 1 --name esgf-solr -p 8983:8983 -p 8984:8984 --network esgf-network  \
                      --mount type=volume,source=solr_data,destination=/esg/solr-index \
                      --constraint 'node.labels.esgf_type==index-node' esgfhub/esgf-solr

# wait for Solr to start
sleep 10

# start esgf-index-node
docker service create --replicas 1 --name esgf-index-node -p 8083:8080 -p 8446:8443 --network esgf-network  \
                      --mount type=bind,source=$ESGF_CONFIG/esg/config/,destination=/esg/config/ \
                      --constraint 'node.labels.esgf_type==index-node' esgfhub/esgf-index-node
