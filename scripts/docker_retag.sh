#!/bin/bash


# Quick and dirt draft of the future script...

################################# SETTINGS #####################################

readonly BASE_DIR_PATH="$(pwd)"
SCRIPT_PARENT_DIR_PATH="$(dirname $0)"; cd "${SCRIPT_PARENT_DIR_PATH}"
readonly SCRIPT_PARENT_DIR_PATH="$(pwd)" ; cd "${BASE_DIR_PATH}"

source "${SCRIPT_PARENT_DIR_PATH}/common"

src_images_hub='esgfhub'
src_tag='1.3'

dest_images_hub='esgfhub'
dest_tag='latest'

for name in ${ESGF_IMAGE_DIR_NAMES[*]}; do
  docker tag "${src_images_hub}/esgf-$name:${src_tag}" "${dest_images_hub}/esgf-$name:${dest_tag}"
  docker push "${dest_images_hub}/esgf-$name:${dest_tag}"
done