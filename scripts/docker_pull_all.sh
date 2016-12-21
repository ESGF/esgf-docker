#!/bin/sh
# Script to pull the latest version of all ESGF Docker images
# Usage:
# ./docker_pull_all.sh [version]

# optional 'version' argument - defaults to 'latest'
version=${1:-latest}

# loop over ordered list of ESGF images
images=('node' 'postgres' 'tomcat' 'solr' 'httpd' 'cog' 'data-node' 'idp-node' 'index-node' 'vsftp' 'solr-cloud')

for img in ${images[*]}; do
   docker pull esgfhub/esgf-$img:$version
done
