#!/bin/bash

echo "Using ESGF_HOSTNAME=$ESGF_HOSTNAME"

# edit settings.py with the latest value of $ESGF_HOST_NAME

# a) the SECRET_KEY = 'changeme1' will be replaced only the very first time the container is run
django_settings_file=/usr/local/esgf-node-manager/src/python/server/nodemgr/nodemgr/settings.py
d=`date`
sk=`echo $d $ESGF_HOSTNAME | sha256sum | awk '{print $1}'`
sed -i s/changeme1/$sk/ $django_settings_file

# b) ALLOWED_HOSTS will be replaced each time with the latest version of $ESGF_HOSTNAME
#sed -i s/changeme2/$ESGF_HOSTNAME/ $django_settings_file
sed -i 's/ALLOWED_HOSTS = .*/ALLOWED_HOSTS = [\"'"${ESGF_HOSTNAME}"'\"]/g' $django_settings_file

# file management and permissions
mkdir -p /esg/log /esg/tasks /esg/config
chmod a+w /esg/log /esg/log/*
chmod a+w /esg/tasks /esg/tasks/*
touch /esg/config/nm.properties
touch /esg/config/registration.xml 
chown nodemgr:nodemgr /esg/config/nm.properties
chown nodemgr:nodemgr /esg/config/registration.xml

# start Node Manager 
esgf-nm-ctl start
esgf-nm-ctl status

# keep container running
tail -f /esg/log/esgfnmd.out.log
