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
esgf_ver="${1-latest}"

images_hub="${DEFAULT_IMAGES_HUB}"

# loop over ordered list of ESGF images
for img in ${ESGF_IMAGE_DIR_NAMES[*]}; do
   docker pull $images_hub/esgf-$img:$esgf_ver
done
