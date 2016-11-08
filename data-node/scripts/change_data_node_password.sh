#!/bin/bash
# script to change the ESGF password used for TDS re-initialization

if [ "${ESGF_PASSWORD}" = "" ] || [ "${CATALINA_HOME}" = "" ];
then
   echo "All env variables: ESGF_PASSWORD, CATALINA_HOME must be set  "
   exit -1
fi

# digest the user password
password_hash=$($CATALINA_HOME/bin/digest.sh -a SHA ${ESGF_PASSWORD} | cut -d ":" -f 2)
echo "Setting digested password=$password_hash"

# replace digested password in tomcat-users.xml
sed -i -- 's/password=\"[^\"]*\"/password=\"'"${password_hash}"'\"/g' /esg/config/tomcat/tomcat-users.xml

# replace clear-text password in esg.ini
# TO DO
