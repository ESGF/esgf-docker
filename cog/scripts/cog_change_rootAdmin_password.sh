#!/bin/bash
# script to change the password of the 'rootAdmin' web site administrator
# - for access to the postgres databases (CoG+ESGF)
# - for web authentication of the rootAdmin user

if [ "${ESGF_PASSWORD}" = "" ] || [ "${ESGF_HOSTNAME}" = "" ];
then
   echo "All env variables: ESGF_PASSWORD, ESGF_HOSTNAME must be set  "
   exit -1
fi

source /usr/local/cog/venv/bin/activate
cd /usr/local/cog/cog_install
python manage.py change_password "https://${ESGF_HOSTNAME}/esgf-idp/openid/rootAdmin" "${ESGF_PASSWORD}"
