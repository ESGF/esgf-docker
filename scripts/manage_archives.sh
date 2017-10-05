#!/bin/bash

readonly BASE_DIR_PATH="$(pwd)"
SCRIPT_PARENT_DIR_PATH="$(dirname $0)"; cd "${SCRIPT_PARENT_DIR_PATH}"
readonly SCRIPT_PARENT_DIR_PATH="$(pwd)" ; cd "${BASE_DIR_PATH}"

set -u

export readonly ARCHIVES_PATH="${ESGF_CONFIG}/archives"

export readonly GRID_SECURITY_CERT_ARCHIVE_NAME='grid_security_certs.tar.xz'
export readonly GRID_SECURITY_CERT_ARCHIVE_PATH="${ARCHIVES_PATH}/${GRID_SECURITY_CERT_ARCHIVE_NAME}"
export readonly GRID_SECURITY_CERT_DIR_PATH="${ESGF_CONFIG}/grid-security/certificates"

export readonly ESGF_CONFIG_ARCHIVE_NAME='esgf_config.tar.xz'
export readonly ESGF_CONFIG_ARCHIVE_PATH="${ARCHIVES_PATH}/${ESGF_CONFIG_ARCHIVE_NAME}"
export readonly ESGF_CONFIG_DIR_PATH="${ESGF_CONFIG}/esg/config"

kernel_name="$(uname)"

case ${kernel_name} in 
  "Linux")
    export TAR='tar'
    ;;
  "Darwin")
    export TAR='gtar' # Must install gtar for MacOSX, look after homebrew package manager.
    ;;
  *)
    export TAR='tar'
    ;;
esac

mkdir -p "${ARCHIVES_PATH}"

# Create the archive of the grid certificates.
echo "> create ${GRID_SECURITY_CERT_ARCHIVE_NAME}"
${TAR} --owner=0 --group=0 --acls -pcJf "${GRID_SECURITY_CERT_ARCHIVE_PATH}" -C "${GRID_SECURITY_CERT_DIR_PATH}/.." "$(basename ${GRID_SECURITY_CERT_DIR_PATH})"

# Create the archive of the esgf configuration files.
echo "> create ${ESGF_CONFIG_ARCHIVE_NAME}"
${TAR} --owner=0 --group=0 --acls -pcJf "${ESGF_CONFIG_ARCHIVE_PATH}" -C "${ESGF_CONFIG_DIR_PATH}/.." "$(basename ${ESGF_CONFIG_DIR_PATH})"