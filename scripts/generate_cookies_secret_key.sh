#!/bin/bash
# script to generate a secret key that is used to encode/decode Oauth authentication cookies

# verify env variable is set
if [ "${ESGF_CONFIG}" = "" ];
then
   echo "Env variable: ESGF_CONFIG must be set  "
   exit -1
fi

# generate a random secret key that does not contain characters that would create problems in the sed replacement below
new_secret_key=`cat /dev/urandom | LC_CTYPE=C tr -dc "[a-zA-Z0-9]" | head -c 24`
old_secret_key='xnVuDEZROQfoBT+scRkaig=='
echo "Generated secret key: $new_secret_key"

# replace in TDS web.xml
sed -i.back 's/'"${old_secret_key}"'/'"${new_secret_key}"'/g' $ESGF_CONFIG/webapps/thredds/WEB-INF/web.xml

# replace in esgf-auth settings.py
sed -i.back 's/'"${old_secret_key}"'/'"${new_secret_key}"'/g' $ESGF_CONFIG/esgf-auth/settings.py
