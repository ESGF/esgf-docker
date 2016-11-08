#!/bin/bash
# script to change the ESGF node hostname
# among other things, this script changes several configuration files in the directory tree under $ESGF_CONFIG

# verify env variables are set
if [ "${ESGF_HOSTNAME}" = "" ] || [ "${ESGF_CONFIG}" = "" ];
then
   echo "All env variables: ESGF_HOSTNAME, ESGF_CONFIG must be set  "
   exit -1
else
   echo "Using ESGF_HOSTNAME=$ESGF_HOSTNAME"
   echo "Using ESGF_CONFIG=$ESGF_CONFIG"
fi

echo "Changing hostname to: $ESGF_HOSTNAME"

# change common ESGF configuration files
sed -i.back 's/my\.esgf\.node/'"${ESGF_HOSTNAME}"'/g' $ESGF_CONFIG/esg/config/esgf.properties
sed -i.back 's/my\.esgf\.node/'"${ESGF_HOSTNAME}"'/g' $ESGF_CONFIG/esg/config/esgf_idp_static.xml
sed -i.back 's/my\.esgf\.node/'"${ESGF_HOSTNAME}"'/g' $ESGF_CONFIG/esg/config/esgf_shards_static.xml

# change apache httpd configuration
sed -i.back 's/my\.esgf\.node/'"${ESGF_HOSTNAME}"'/g' $ESGF_CONFIG/httpd/conf/esgf-httpd.conf

# change CoG settings
#sed -i.back 's/my\.esgf\.node/'"${ESGF_HOSTNAME}"'/g' $ESGF_CONFIG/cog/cog_config/cog_settings.cfg

# change TDS access control filters
sed -i.back 's/my\.esgf\.node/'"${ESGF_HOSTNAME}"'/g' $ESGF_CONFIG/webapps/thredds/WEB-INF/web.xml
