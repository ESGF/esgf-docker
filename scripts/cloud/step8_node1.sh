#!/bin/sh
# node: acce-build1.dyndns.org
# Deployes ESGF data-node services

export ESGF_CONFIG=~/esgf/data-node-config
echo "Using $ESGF_CONFIG"

docker service create --replicas 1 --name esgf-data-node -p 8082:8080 -p 8445:8443 --network db-network --network esgf-network   \
                      --mount type=volume,source=tds_data,destination=/esg/content/thredds/ \
                      --mount type=bind,source=$ESGF_CONFIG/grid-security/certificates/,destination=/etc/grid-security/certificates/ \
                      --mount type=bind,source=$ESGF_CONFIG/esg/config/,destination=/esg/config/ \
                      --mount type=bind,source=$ESGF_CONFIG/webapps/thredds/WEB-INF/web.xml,destination=/usr/local/tomcat/webapps/thredds/WEB-INF/web.xml \
                      --mount type=bind,source=$ESGF_CONFIG/tomcat/bin/setenv.sh,destination=/usr/local/tomcat/bin/setenv.sh \
                      --constraint 'node.labels.esgf_type==data-node' esgfhub/esgf-data-node
