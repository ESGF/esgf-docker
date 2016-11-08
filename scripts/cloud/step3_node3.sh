#!/bin/sh
# node: acce-build3.dyndns.org
# Makes this ndoe join the swarm. It needs the swarm worker token as input.

token_worker=$1
if [ $token_worker = '' ]; then
   echo "Worker token is null, exiting"
   exit -1
fi

export MANAGER_IP=172.31.4.166
docker swarm join --token $token_worker $MANAGER_IP:2377
