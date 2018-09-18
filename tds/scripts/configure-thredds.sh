#!/bin/bash

set -euo pipefail

. /esg/bin/functions.sh

#####
## This script sets up the THREDDS config files
#####

# First, set up /esg/config
/esg/bin/build-config.sh /esg/config
# Then web.xml
/esg/bin/build-config.sh "$CATALINA_HOME/webapps/thredds/WEB-INF"

# tomcat-users.xml requires us to create a digest of the specified password
# Using gomplate here allows us to benefit from _FILE fallback
PASSWORD="$(/esg/bin/gomplate -i '{{ getenv "ESGF_TDS_ADMIN_PASSWORD" }}')"
export ESGF_TDS_ADMIN_PASSWORD_DIGEST="$($CATALINA_HOME/bin/digest.sh -a sha-512 -h org.apache.catalina.realm.MessageDigestCredentialHandler "$PASSWORD" | cut -d':' -f2)"
# Then build the config
/esg/bin/build-config.sh "$CATALINA_HOME/conf"

# Build the thredds content root
/esg/bin/build-config.sh /esg/content/thredds
