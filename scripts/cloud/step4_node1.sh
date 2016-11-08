#!/bin/sh
# node: acce-build1.dyndns.org
# Initialize the ESGF configuration on this node

export ESGF_CONFIG=~/esgf/front-end-config
export ESGF_HOSTNAME=`hostname`
mkdir -p $ESGF_CONFIG
# cd to parent directory
cd ../
./esgf_node_init.sh
