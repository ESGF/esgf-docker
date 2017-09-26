#!/bin/bash
# script to build (and optionally push) all ESGF Docker images
# 
# You may override default setting by exporting the following variables:
#   - ESGF_VERSION for the tag of the images
#   - ESGF_IMAGES_HUB for the hub of the images
#   - ESGF_REPO for the repository of the packages
# 
# Usage:
# docker_build_and_push_all.sh -h
# Example:
# docker_build_and_push_all.sh -v 1.0 --push-it

################################# SETTINGS #####################################

readonly BASE_DIR_PATH="$(pwd)"
SCRIPT_PARENT_DIR_PATH="$(dirname $0)"; cd "${SCRIPT_PARENT_DIR_PATH}"
readonly SCRIPT_PARENT_DIR_PATH="$(pwd)" ; cd "${BASE_DIR_PATH}"

source "${SCRIPT_PARENT_DIR_PATH}/common"

readonly DEFAULT_VERSION=${ESGF_VERSION-devel}

readonly GEOLITECITY_PARENT_DIR_PATH="${SCRIPT_PARENT_DIR_PATH}/../data-node/dashboard"
readonly GEOLITECITY_FILE_PATH="${GEOLITECITY_PARENT_DIR_PATH}/GeoLiteCity.dat.gz"

set -u

############################ CONTROL VARIABLES #################################

# required version
esgf_ver="${DEFAULT_VERSION}"

# optional 'push' argument
pushit="${FALSE}"

has_only_push="${FALSE}"

# images hub
images_hub="${DEFAULT_IMAGES_HUB}"

packages_repo="${DEFAULT_PACKAGE_REPO}"

assumeyes="${FALSE}"

################################ FUNCTIONS #####################################

function build_and_push() {
  # function parameters
  img="esgf-$1:${esgf_ver}"
  
  if [[ "${has_only_push}" = "${FALSE}" ]]; then
    echo -e "***** BUILDING MODULE $img\n"

    # build the module
    docker build --no-cache --build-arg "ESGF_REPO=${packages_repo}" \
                            --build-arg "ESGF_IMAGES_HUB=${images_hub}" \
                            --build-arg "ESGF_VERSION=${esgf_ver}" \
                            -t ${images_hub}/$img .
  
    #docker build --no-cache -t $images_hub/$img .
  fi

  # optionally push the module to Docker Hub
  if [[ $pushit == "${TRUE}" ]]; then
       docker push $images_hub/$img
  fi
}

function usage
{
  echo -e "usage:\n\
  \n${SCRIPT_NAME}\
  \n-v | --version <string> the version of the images\
  \n-i | --images-hub <name> the name of the images hub\
  \n-r | --package-repo <url> the name of the packages repository\
  \n-p | --push-it push the images to the hub\
  \n-P | --only-push push the images already built to the hub\
  \n-y | --assumeyes answer yes to all questions\
  \n-h | --help : print usage\
\n\
\n\
You may override default settings by exporting the following environment variables:\n\
  - ESGF_VERSION for the tag of the images-hub\n\
  - ESGF_IMAGES_HUB for the hub of the images\n\
  - ESGF_REPO for the repository of the packages"
}

################################## MAIN ########################################

params="$(getopt -o v:i:r:pPyh -l version:,images-hub:,packages-repo:,push-it,only-push,assumeyes,help --name "$(basename "$0")" -- "$@")"

if [ ${?} -ne 0 ]
then
    usage
    exit ${SETTINGS_ERROR}
fi

eval set -- "$params"
unset params

while true; do
  case $1 in
    -v|--version)
      case "${2}" in
        "") echo "#### missing value. Abort ####"; exit ${SETTINGS_ERROR} ;;
        *)  esgf_ver="${2}" ; shift 2 ;;
      esac ;;
    -i|--images-hub)
      case "${2}" in
        "") echo "#### missing value. Abort ####"; exit ${SETTINGS_ERROR} ;;
        *)  images_hub="${2}" ; shift 2 ;;
      esac ;;
    -r|--pacakges-repo)
      case "${2}" in
        "") echo "#### missing value. Abort ####"; exit ${SETTINGS_ERROR} ;;
        *)  packages_repo="${2}" ; shift 2 ;;
      esac ;;
    -h|--help)
      usage
      exit ${SUCCESS_CODE}
      ;;
    -p|--push-it)
      pushit="${TRUE}" 
      shift 1 ;;
    -P|--only-push)
      pushit="${TRUE}"
      has_only_push="${TRUE}"
      shift 1 ;;
    -y|--assumeyes)
      assumeyes="${TRUE}" 
      shift 1 ;;
    --)
      shift
      break
      ;;
    *)
      usage
      echo "#### abort ####"
      exit ${SETTINGS_ERROR}
      ;;
  esac
done

echo -e "building all the images with VERSION=$esgf_ver PUSH=$pushit HUB=$images_hub REPO=$packages_repo\n"

if [[ "${assumeyes}" = "${FALSE}" ]]; then
  ask_binary_question "Do you want to continue ?"

  if [ ${?} -ne 0 ]; then
    exit ${CANCEL_CODE}
  fi
fi

if [[ "${pushit}" = "${TRUE}" && "${assumeyes}" = "${FALSE}" ]]; then
  ask_binary_question "Are you log in docker ?"

  if [ ${?} -ne 0 ]; then
    echo "issue: docker login -u <docker_id>"
    exit ${CANCEL_CODE}
  fi
fi

pushd "${GEOLITECITY_PARENT_DIR_PATH}" > /dev/null
wget -N -nv "${packages_repo}/dist/devel/geoip/GeoLiteCity.dat.gz"
popd > /dev/null

# loop over ordered list of ESGF images
for subdir in ${ESGF_IMAGE_DIR_NAMES[*]}; do
   # cd to parallel directory
   cd "${SCRIPT_PARENT_DIR_PATH}/../$subdir"
   build_and_push $subdir
done

cd "${BASE_DIR_PATH}"

exit ${SUCCESS_CODE}
