#!/bin/bash

# Example: ./docker_retag.sh -f "personalhub:devel" -t "esgfhub:1.4"

################################# SETTINGS #####################################

readonly BASE_DIR_PATH="$(pwd)"
SCRIPT_PARENT_DIR_PATH="$(dirname $0)"; cd "${SCRIPT_PARENT_DIR_PATH}"
readonly SCRIPT_PARENT_DIR_PATH="$(pwd)" ; cd "${BASE_DIR_PATH}"

set -u

source "${SCRIPT_PARENT_DIR_PATH}/common"

################################ FUNCTIONS #####################################

function usage
{
  echo -e "usage:\n\
  \n${SCRIPT_NAME}\
  \n-f | --from <image_hub:tag> : the pattern of the retagged images\
  \n-t | --to <image_hub:tag> : the pattern of the new images\
  \n-p | --push-it : push the new images into the hub\
  \n-y | --assumeyes : answer yes to all questions\
  \n-h | --help : print usage"
}

############################ CONTROL VARIABLES #################################

pushit="${FALSE}"

assumeyes="${FALSE}"

from_pattern=""
to_pattern=""
from_hub=""
from_tag=""
to_hub=""
to_tag=""

################################## MAIN ########################################

# handle options

params="$(getopt -o f:t:pyh -l from:,to:,push-it,assumeyes,help --name "$(basename "$0")" -- "$@")"

if [ ${?} -ne 0 ]
then
    usage
    exit ${SETTINGS_ERROR}
fi

eval set -- "$params"
unset params

while true; do
  case $1 in
    -f|--from)
      case "${2}" in
        "") echo "#### missing value. Abort ####"; exit ${SETTINGS_ERROR} ;;
        *)  from_pattern="${2}" ; shift 2 ;;
      esac ;;
    -t|--to)
      case "${2}" in
        "") echo "#### missing value. Abort ####"; exit ${SETTINGS_ERROR} ;;
        *)  to_pattern="${2}" ; shift 2 ;;
      esac ;;
    -p|--push-it)
      pushit="${TRUE}" 
      shift 1 ;;
    -h|--help)
      usage
      exit ${SUCCESS_CODE}
      ;;
    -y|--assumeyes)
      assumeyes="${TRUE}" 
      shift 1
      ;;
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

# check from pattern
if [[ -z "${from_pattern}" ]]; then
  echo "#### missing pattern of the retagged images ####"
  usage
  echo "#### abort ####"
  exit ${SETTINGS_ERROR}
fi

from_pattern_array=(${from_pattern//:/ })

if [ ${#from_pattern_array[*]} -ne 2 ]; then
  echo "#### retagged images pattern unrecognized ####"
  usage
  echo "#### abort ####"
  exit ${SETTINGS_ERROR}
fi

from_hub="${from_pattern_array[0]}"
from_tag="${from_pattern_array[1]}"
unset from_pattern
unset from_pattern_array

# check to pattern
if [[ -z "${to_pattern}" ]]; then
  echo "#### missing pattern of the new images####"
  usage
  echo "#### abort ####"
  exit ${SETTINGS_ERROR}
fi

to_pattern_array=(${to_pattern//:/ })

if [ ${#to_pattern_array[*]} -ne 2 ]; then
  echo "#### new images pattern unrecognized ####"
  usage
  echo "#### abort ####"
  exit ${SETTINGS_ERROR}
fi

to_hub="${to_pattern_array[0]}"
to_tag="${to_pattern_array[1]}"
unset to_pattern
unset to_pattern_array

# dislay settings
echo -e "retag all the images from HUB=${from_hub} VERSION=${from_tag} to HUB=${to_hub} VERSION=${to_tag} with PUSH=$pushit ?\n"

if [[ "${assumeyes}" = "${FALSE}" ]]; then
  ask_binary_question "Do you want to continue ?"

  if [ ${?} -ne 0 ]; then
    exit ${CANCEL_CODE}
  fi
fi

# display pushit question
if [[ "${pushit}" = "${TRUE}" && "${assumeyes}" = "${FALSE}" ]]; then
  ask_binary_question "Are you log in docker ?"

  if [ ${?} -ne 0 ]; then
    echo "issue: docker login -u <docker_id>"
    exit ${CANCEL_CODE}
  fi
fi

for name in ${ESGF_IMAGE_DIR_NAMES[*]}; do
  from_img="${from_hub}/${ESGF_IMAGE_PREFIX}${name}:${from_tag}"
  to_img="${to_hub}/${ESGF_IMAGE_PREFIX}${name}:${to_tag}"

  docker tag "${from_img}" "${to_img}"
  
  if [[ $pushit == "${TRUE}" ]]; then
    docker push "${to_img}"
  fi
done

echo "**** retag successful ****"
exit ${SUCCESS_CODE}