#!/bin/bash
# script to change the password that CoG uses to access the Postgres database

if [ "${ESGF_PASSWORD}" = "" ] || [ "${COG_CONFIG_DIR}" = "" ];
then
   echo "All env variables: ESGF_PASSWORD, COG_CONFIG_DIR must be set  "
   exit -1
fi

sed -i 's/DATABASE_PASSWORD = .*/DATABASE_PASSWORD = '"${ESGF_PASSWORD}"'/g' $COG_CONFIG_DIR/cog_settings.cfg
sed -i 's/dbsuper:.*@esgf-postgres/dbsuper:'"${ESGF_PASSWORD}"'@esgf-postgres/g' $COG_CONFIG_DIR/cog_settings.cfg
