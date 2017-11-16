#!/bin/bash
# script to generate a secret key that is used to encode/decode Oauth authentication cookies

# verify env variable is set
if [ "${ESGF_CONFIG}" = "" ];
then
   echo "Env variable: ESGF_CONFIG must be set  "
   exit -1
fi

# generate a random secret key to encrypt/decript cookies
# chose a key that does not contain characters that would create problems in the sed replacement below
# IMPORTANT: for base64 encoding/decofing to work, the key must be composed of a multiple of 3 characters
# here we are using 22 characters and padding it with '=='
new_secret_key=`cat /dev/urandom | LC_CTYPE=C tr -dc "[a-zA-Z0-9]" | head -c 22`
new_secret_key="${new_secret_key}=="
#old_secret_key='xnVuDEZROQfoBT+scRkaig=='
echo "Generated ESGF_SECRET_KEY key: $new_secret_key"

# replace in TDS web.xml
sed -i.back 's/ESGF_SECRET_KEY/'"${new_secret_key}"'/g' $ESGF_CONFIG/webapps/thredds/WEB-INF/web.xml

# replace in esgf_auth_config.json and settings.py (?)
#sed -i.back 's/'"${old_secret_key}"'/'"${new_secret_key}"'/g' $ESGF_CONFIG/esgf-auth/settings.py
sed -i.back 's/.*ESGF_SECRET_KEY.*/\"ESGF_SECRET_KEY\":\"'"${new_secret_key}"'\",/g' $ESGF_CONFIG/esg/config/esgf_auth_config.json

# generate a second secret key to be used by Django webapp
webapp_secret_key=`cat /dev/urandom | LC_CTYPE=C tr -dc "[a-zA-Z0-9]" | head -c 40`
echo "Generated WEBAPP_SECRET_KEY key: $webapp_secret_key"
sed -i.back 's/.*WEBAPP_SECRET_KEY.*/\"WEBAPP_SECRET_KEY\":\"'"${webapp_secret_key}"'\",/g' $ESGF_CONFIG/esg/config/esgf_auth_config.json

