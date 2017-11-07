#!/bin/sh
# 
# Script to setup a Docker Swarm composed of 1 single node on a MacOSX laptop.

# create all VMs
docker-machine create --driver virtualbox --virtualbox-memory 2048 node1
docker-machine ls

# start the swarm
eval $(docker-machine env node1)
export MANAGER_IP=`docker-machine ip node1`
docker swarm init --advertise-addr $MANAGER_IP
token_worker=`docker swarm join-token --quiet worker`
token_manager=`docker swarm join-token --quiet manager`

# drain the swarm manager to prevent assigment of tasks
#docker node update --availability drain node1

# assign functional labels to the single node
eval $(docker-machine env node1)
docker node ls
docker node update --label-add esgf_front_node=true node1
docker node update --label-add esgf_db_node=true node1
docker node update --label-add esgf_index_node=true node1
docker node update --label-add esgf_idp_node=true node1
docker node update --label-add esgf_solr_node=true node1
docker node update --label-add esgf_data_node=true node1
