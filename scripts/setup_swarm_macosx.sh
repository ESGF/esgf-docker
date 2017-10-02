#!/bin/sh
# 
# Script to setup a Docker Swarm composed of 6 nodes on a MacOSX laptop.

# create all VMs
# (assign more memory to last node which will be the data-node)
docker-machine create --driver virtualbox node1
docker-machine create --driver virtualbox node2
docker-machine create --driver virtualbox node3
docker-machine create --driver virtualbox node4
docker-machine create --driver virtualbox node5
docker-machine create --driver virtualbox --virtualbox-memory 2048 node6
docker-machine ls

# start the swarm
eval $(docker-machine env node1)
export MANAGER_IP=`docker-machine ip node1`
docker swarm init --advertise-addr $MANAGER_IP
token_worker=`docker swarm join-token --quiet worker`
token_manager=`docker swarm join-token --quiet manager`

# drain the swarm manager to prevent assigment of tasks
#docker node update --availability drain node1

# join the swarm
for i in `seq 2 6`;
do
   eval $(docker-machine env node$i)
   docker swarm join --token $token_worker $MANAGER_IP:2377
done

docker node ls

# assign functional labels to nodes
eval $(docker-machine env node1)
docker node update --label-add esgf_front_node=true node1
docker node update --label-add esgf_db_node=true node2
docker node update --label-add esgf_index_node=true node3
docker node update --label-add esgf_idp_node=true node4
docker node update --label-add esgf_solr_node=true node5
docker node update --label-add esgf_data_node=true node6
