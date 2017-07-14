#!/bin/bash

# command line arguments

# ESGF_HOSTNAME=.....
export ESGF_HOSTNAME=$1
echo "ESGF_HOSTNAME=$ESGF_HOSTNAME"

# esgf_flag=false/true
export ESGF_FLAG=$2
echo "ESGF_FLAG=$ESGF_FLAG"

# runserver=true/false
export RUNSERVER=$3
echo "RUNSERVER=$RUNSERVER"

# execute CoG initialization
if [ $INIT == "true" ]; then
   echo "Executing CoG initialization..."
   scriptdir=`dirname "$BASH_SOURCE"`
   $scriptdir/docker-init.sh $ESGF_HOSTNAME $ESGF_FLAG
fi

# start django server in virtual environment
if [ $RUNSERVER == "true" ]; then
   echo "Starting CoG server through supervisor daemon"
   # start supervisor --> cog
   supervisord -c /etc/supervisord.conf
   sleep 2
   tail -f /tmp/cog.log
fi
