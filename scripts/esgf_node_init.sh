#! /bin/bash
# Driver script to initialize an ESGF node
# Configuration is provided via env variables:
# $ESGF_HOSTNAME : FQDN of ESGF host
# $ESGF_CONFIG : root directory where all site specific configuration is stored
# $ESGF_VERSION : version of ESGF/Docker distribution
#
# This script will:
# o initialize the content of a new site-specific configuration directory: <configuration directory>
# o generate new self-signed certificates for the given <hostname>
# o change all site configuration to use <hostname>

readonly BASE_DIR_PATH="$(pwd)"
SCRIPT_DIR_PATH="$(dirname $0)"; cd "${SCRIPT_DIR_PATH}"
readonly SCRIPT_DIR_PATH="$(pwd)" ; cd "${BASE_DIR_PATH}"

# verify env variables are set
if [ "${ESGF_HOSTNAME}" = "" ] || [ "${ESGF_CONFIG}" = "" ] || [ "${ESGF_VERSION}" = "" ];
then
   echo "All env variables: ESGF_HOSTNAME, ESGF_CONFIG, ESGF_VERSION must be set  "
   exit -1
else
   echo "Using ESGF_HOSTNAME=$ESGF_HOSTNAME"
   echo "Using ESGF_CONFIG=$ESGF_CONFIG"
   echo "Using ESGF_VERSION=$ESGF_VERSION"
fi

# initialize the node configuration directory
echo ""
echo "Initializing the node configuration directory with default content..."
echo "Removing any existing content..."
if [ -e $ESGF_CONFIG ]
then
   rm -rf $ESGF_CONFIG/*
else
   mkdir -p $ESGF_CONFIG
fi
cp -R $SCRIPT_DIR_PATH/../esgf_config/* $ESGF_CONFIG/.
# empty directory needed for CoG initialization
mkdir -p $ESGF_CONFIG/cog/cog_config

# generate new certificates
echo ""
echo "Generating new self-signed certificates..."
$SCRIPT_DIR_PATH/generate_certificates.sh

# change node configuration to use new hostname
echo ""
echo "Changing configuration for hostname=$ESGF_HOSTNAME..."
$SCRIPT_DIR_PATH/change_hostname.sh

echo "... ESGF node initialization completed."
