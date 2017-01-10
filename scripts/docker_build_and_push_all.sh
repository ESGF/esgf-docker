#!/bin/sh
# script to build (and optionally push) all ESGF Docker images
# note: must define env variable ESGF_REPO to point to ESGF distribution repository
# Example: export ESGF_REPO=http://distrib-coffee.ipsl.jussieu.fr/pub/esgf
#
# Usage:
# docker_build_and_push_all.sh <version> [--pushit] 
# Example:
# docker_build_and_push_all.sh 1.0 --pushit

function build_and_push() {

  # function parameters
  img="esgf-$1:$2"
  pushit=$3
  echo "BUILDING MODULE=$img PUSH=$pushit\n"

  # build the module
  #docker build --no-cache --build-arg ESGF_REPO=$ESGF_REPO -t esgfhub/$img .
  docker build --no-cache -t esgfhub/$img .

  # optionally push the module to Docker Hub
  if [[ $pushit == *"push"* ]]; then
       docker push esgfhub/$img
  fi

}

# required version
version=$1

# optional 'push' argument
pushit=${2:-false}
 
# this directory
wrkdir=`pwd`

# loop over ordered list of ESGF images
subdirs=('node' 'postgres' 'tomcat' 'solr' 'httpd' 'cog' 'data-node' 'idp-node' 'index-node' 'vsftp' 'solr-cloud')

for subdir in ${subdirs[*]}; do
   # cd to parallel directory
   cd "$wrkdir/../$subdir"
   build_and_push $subdir $version $pushit
done
