#! /bin/bash
# Driver script to initialize an ESGF node
# Configuration is provided via env variables:
# $ESGF_HOSTNAME : FQDN of ESGF host
# $ESGF_CONFIG : root directory where all site specific configuration is stored
#
# This script will:
# o initialize the content of a new site-specific configuration directory: <configuration directory>
# o generate new self-signed certificates for the given <hostname>
# o change all site configuration to use <hostname>

# verify env variables are set
if [ "${ESGF_HOSTNAME}" = "" ] || [ "${ESGF_CONFIG}" = "" ];
then
   echo "All env variables: ESGF_HOSTNAME, ESGF_CONFIG must be set  "
   exit -1
else
   echo "Using ESGF_HOSTNAME=$ESGF_HOSTNAME"
   echo "Using ESGF_CONFIG=$ESGF_CONFIG"
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
cp -R ../esgf_config/* $ESGF_CONFIG/.
# empty directory needed for CoG initialization
mkdir -p $ESGF_CONFIG/cog/cog_config

# generate new certificates
echo ""
echo "Generating new self-signed certificates..."
./generate_certificates.sh

# change node configuration to use new hostname
echo ""
echo "Changing configuration for hostname=$ESGF_HOSTNAME..."
./change_hostname.sh

echo "... ESGF node initialization completed."
