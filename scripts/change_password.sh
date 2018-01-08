#!/bin/bash
# script to change the root ESGF password
# the new password is obtained from the env variable ESGF_PASSWORD
# some password changes are executed directly inside each container

readonly BASE_DIR_PATH="$(pwd)"
SCRIPT_PARENT_DIR_PATH="$(dirname $0)"; cd "${SCRIPT_PARENT_DIR_PATH}"
readonly SCRIPT_PARENT_DIR_PATH="$(pwd)" ; cd "${BASE_DIR_PATH}"

if [ "${ESGF_PASSWORD}" = "" ] || [ "${ESGF_CONFIG}" = "" ];
then
   echo "All env variables: ESGF_PASSWORD, ESGF_CONFIG must be set  "
   exit -1
fi

# change password inside (running) postgres container
docker start postgres
# give postgres time to start
sleep 3
docker exec -it postgres /bin/bash -c "export ESGF_PASSWORD=${ESGF_PASSWORD} && /usr/local/bin/postgres_change_password.sh"
docker stop postgres

# change password in common ESGF configuration files under $ESGF_CONFIG/esg/config
echo ${ESGF_PASSWORD} > ${ESGF_CONFIG}/esg/config/.esg_pg_pass
echo ${ESGF_PASSWORD} > ${ESGF_CONFIG}/esg/config/.esgf_pass
#sed -i.back 's/db.password=.*/db.password='"${ESGF_PASSWORD}"'/g' ${ESGF_CONFIG}/esg/config/esgf.properties
# must re-create the archive files containing the ESGF password
echo "Creating archives"
$SCRIPT_PARENT_DIR_PATH/manage_archives.sh


# change password to access the postgres databases in CoG settings file
# from within the running cog container
docker start cog
docker exec -it cog /bin/bash -c "export ESGF_PASSWORD=${ESGF_PASSWORD} && /usr/local/bin/cog_change_database_password.sh"
#docker exec -it cog /bin/bash -c "export ESGF_PASSWORD=${ESGF_PASSWORD} && export ESGF_HOSTNAME=${ESGF_HOSTNAME} && /usr/local/bin/cog_change_rootAdmin_password.sh"
docker stop cog

# change password inside (running) data-node container
docker start tds
docker exec -it tds /bin/bash -c "export ESGF_PASSWORD=${ESGF_PASSWORD} && /usr/local/bin/change_tds_password.sh"
docker stop tds

# TODO: change password in file esg.ini inside esgf-publisher container
