#!/bin/sh
# Script to pull the latest version of all ESGF Docker images
# Usage:
# ./docker_pull_all.sh

# loop over ordered list of ESGF images
images=('node' 'postgres' 'tomcat' 'solr' 'httpd' 'cog' 'data-node' 'idp-node' 'index-node' 'vsftp')

for img in ${images[*]}; do
   docker pull esgfhub/esgf-$img
done
