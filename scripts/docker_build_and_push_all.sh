#!/bin/sh
# script to build (and optionally push) all ESGF Docker images
# Usage:
# docker_build_and_push_all.sh [--push] 

function build_and_push() {

  # function parameters
  img=esgf-$1
  pushit=$2
  echo "\nBUILDING MODULE=$img PUSH=$pushit\n"

  # build the module
  docker build --no-cache -t esgfhub/$img .

  # optionally push the module to Docker Hub
  if [ $pushit == '--push' ]; then
       docker push esgfhub/$img
  fi

}

# optional 'push' argument
pushit=${1:-false}
 
# this directory
wrkdir=`pwd`

# loop over ordered list of ESGF images
subdirs=('node' 'postgres' 'tomcat' 'solr' 'httpd' 'cog' 'data-node' 'idp-node' 'index-node' 'vsftp' 'solr-cloud')

for subdir in ${subdirs[*]}; do
   # cd to parallel directory
   cd "$wrkdir/../$subdir"
   build_and_push $subdir $pushit
done
