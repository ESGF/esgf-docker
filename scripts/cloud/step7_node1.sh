#!/bin/sh
# node: acce-build1.dyndns.org
# Deployes services on the front-end node

export ESGF_CONFIG=~/esgf/front-end-config
export ESGF_HOSTNAME=`hostname`

# create networks
docker network create -d overlay db-network
docker network create -d overlay esgf-network

# assign labels to nodes
docker node update --label-add esgf_type=front-end acce-build1.dyndns.org
docker node update --label-add esgf_type=data-node acce-build2.dyndns.org
docker node update --label-add esgf_type=index-node acce-build3.dyndns.org

# start Postgres database on dedicated network
docker service create --replicas 1 --name esgf-postgres -p 5432:5432 --network db-network  --constraint 'node.labels.esgf_type==front-end' esgfhub/esgf-postgres
# wait for database to initialize
sleep 10

# start IdP connecting to both networks
docker service create --replicas 1 --name esgf-idp-node -p 8444:8443 --network esgf-network --network db-network  \
                      --mount type=bind,source=$ESGF_CONFIG/esg/config/,destination=/esg/config/ \
                      --constraint 'node.labels.esgf_type==front-end' esgfhub/esgf-idp-node

# start 'cog' container
# note that the cog software and virtual environment are mounted onto internal docker volumes
# while the site-specific cog configuration and data is persisted into the local file system
# FIXME: keep the container running without the django server
docker service create --replicas 1 --name esgf-cog --network esgf-network --network db-network \
                      --mount type=volume,source=cog_install,destination=/usr/local/cog/cog_install/ \
                      --mount type=volume,source=cog_venv,destination=/usr/local/cog/venv/ \
                      --mount type=bind,source=$ESGF_CONFIG/cog/cog_config/,destination=/usr/local/cog/cog_config/ \
                      --mount type=bind,source=$ESGF_CONFIG/esg/config/,destination=/esg/config/ \
                      --constraint 'node.labels.esgf_type==front-end' esgfhub/esgf-cog \
                      $ESGF_HOSTNAME true true

# start 'httpd' service
# note that this service uses the cog software installed onto the docker volume
# and site specific configuration and data from the local filesystem
docker service create --replicas 1 --name esgf-httpd -p 80:80 -p 443:443 --network esgf-network --network db-network   \
                      --mount type=volume,source=cog_install,destination=/usr/local/cog/cog_install/ \
                      --mount type=volume,source=cog_venv,destination=/usr/local/cog/venv/ \
                      --mount type=bind,source=$ESGF_CONFIG/cog/cog_config/,destination=/usr/local/cog/cog_config/ \
                      --mount type=bind,source=$ESGF_CONFIG/httpd/certs/,destination=/etc/certs/ \
                      --mount type=bind,source=$ESGF_CONFIG/httpd/conf/,destination=/etc/httpd/conf.d/ \
                      --mount type=bind,source=$ESGF_CONFIG/grid-security/certificates/,destination=/etc/grid-security/certificates/ \
                      --mount type=bind,source=$ESGF_CONFIG/esg/config/,destination=/esg/config/ \
                      --constraint 'node.labels.esgf_type==front-end' esgfhub/esgf-httpd
