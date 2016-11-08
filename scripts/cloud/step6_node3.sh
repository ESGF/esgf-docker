#!/bin/sh
# node: acce-build3.dyndns.org
# Initialize the ESGF configuration on this node

export ESGF_CONFIG=~/esgf/index-node-config
export ESGF_HOSTNAME=`hostname`
mkdir -p $ESGF_CONFIG
# cd to parent directory
cd ../
./esgf_node_init.sh
