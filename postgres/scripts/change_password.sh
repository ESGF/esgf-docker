#!/bin/bash

if [ "$ESGF_PASSWORD" = "" ]
then
   echo "Env variable ESGF_PASSWORD is not set, exiting"
   exit -1
fi


# change password in postgres database
# (uses old password in /root/.pgpass for access)
echo "ALTER USER dbsuper WITH ENCRYPTED PASSWORD '${ESGF_PASSWORD}';" > ./change_password.sql
echo "ALTER USER esgcet WITH ENCRYPTED PASSWORD '${ESGF_PASSWORD}';" >> ./change_password.sql
psql -U dbsuper esgcet < ./change_password.sql

# set new password in /root/.pgpass
# but only if previous command succeded!
if [ $? == 0 ]
then
   echo "localhost:5432:cogdb:dbsuper:${ESGF_PASSWORD}" > /root/.pgpass
   echo "localhost:5432:esgcet:dbsuper:${ESGF_PASSWORD}" >> /root/.pgpass
   chmod 0600 /root/.pgpass
fi

# clean up
rm ./change_password.sql
