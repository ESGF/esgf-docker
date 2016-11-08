#!/bin/sh
# node: acce-build1.dyndns.org
# Initializes the swarm, starts swarm visualizer tool

export MANAGER_IP=172.31.4.166
docker swarm init --advertise-addr $MANAGER_IP
token_worker=`docker swarm join-token --quiet worker`
echo $token_worker

docker network create -d overlay esgf-network
docker network create -d overlay db-network
docker run -it -d -p 8080:8080 -e HOST=$MANAGER_IP -e PORT=8080 -v /var/run/docker.sock:/var/run/docker.sock --name visualizer manomarks/visualizer
