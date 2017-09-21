#!/bin/bash
# Script to pull the latest version of all ESGF Docker images
# Usage:
# ./docker_pull_all.sh [version]
# Example: # ./docker_pull_all.sh 1.1

readonly BASE_DIR_PATH="$(pwd)"
SCRIPT_PARENT_DIR_PATH="$(dirname $0)"; cd "${SCRIPT_PARENT_DIR_PATH}"
readonly SCRIPT_PARENT_DIR_PATH="$(pwd)" ; cd "${BASE_DIR_PATH}"

source "${SCRIPT_PARENT_DIR_PATH}/common"

# optional 'version' argument - defaults to 'latest'
version="${DEFAULT_VERSION}"

if [[ -n "${1}" ]]; then
  version="${1}"
fi

images_hub="${DEFAULT_IMAGES_HUB}"

echo $version
echo $images_hub

exit 0

# loop over ordered list of ESGF images
images=('node' 'postgres' 'tomcat' 'solr' 'httpd' 'cog' 'data-node' 'idp-node' 'index-node' 'vsftp' 'solr-cloud')

for img in ${images[*]}; do
   docker pull $images_hub/esgf-$img:$version
done
