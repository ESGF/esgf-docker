#!/bin/bash
# Script to retag all ESGF Docker images
# Usage:
# ./docker_pull_all.sh [old_version] [new_version]
# Example: # ./docker_pull_all.sh devel 1.3

readonly BASE_DIR_PATH="$(pwd)"
SCRIPT_PARENT_DIR_PATH="$(dirname $0)"; cd "${SCRIPT_PARENT_DIR_PATH}"
readonly SCRIPT_PARENT_DIR_PATH="$(pwd)" ; cd "${BASE_DIR_PATH}"

source "${SCRIPT_PARENT_DIR_PATH}/common"

# input arguments
old_version=${1}
new_version=${2}


# loop over ordered list of ESGF images
for img in ${ESGF_IMAGE_DIR_NAMES[*]}; do
   old_image="esgfhub/esgf-$img:$old_version"
   new_image="esgfhub/esgf-$img:$new_version"
   # IMPORTANT: Must match trailing space to not confuse matching'esgf-solr' and 'esgf-solr-cloud' or 'esgf-node' and 'esgf-node-manager'
   ID="$(docker images | grep esgf-$img[[:space:]] | grep $old_version | head -n 1 | awk '{print $3}')"
   echo "Ratagging $old_image ID=$ID to $new_image"
   docker tag $ID esgfhub/esgf-$img:$new_version
   docker push $new_image
done
