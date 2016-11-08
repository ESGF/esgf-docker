#!/bin/sh
# ESGF installation with Docker Swarm on local laptop.
# Example script that installs the ESGF software stack 
# on a set of local VMs running Docker Engine in Swarm mode.

# The swarm is composed of:
# - 'swarm-manager' manager node, running no ESGF services
# - 'swarm-db-worker' worker node, configured to run the ESGF postgres database
# - 'swarm-idp-worker' worker node, configured to run the ESGF Idenity Provider
# - 'swarm-index-worker' worker node, configured to run Solr and the ESGF Search web application
# - 'swarm-data-node-worker' worker node, configured the TDS and ORP web applications
# - 'swarm-front-end-worker' worker node, configured to run the CoG web UI front-ended by the Apache httpd daemon

# create all VMs
docker-machine create -d virtualbox swarm-manager
docker-machine create -d virtualbox swarm-db-worker
docker-machine create -d virtualbox swarm-idp-worker
docker-machine create -d virtualbox swarm-index-worker
docker-machine create -d virtualbox swarm-front-end-worker
docker-machine create -d virtualbox --virtualbox-memory 2048 swarm-data-node-worker

# start the swarm
eval $(docker-machine env swarm-manager)
export MANAGER_IP=`docker-machine ip swarm-manager`
docker swarm init --advertise-addr $MANAGER_IP
token_worker=`docker swarm join-token --quiet worker`
token_manager=`docker swarm join-token --quiet manager`

# drain the swarm manager to prevent assigment of tasks
docker node update --availability drain swarm-manager

# start swarm visualizer on swarm manager
docker run -it -d -p 5000:5000 -e HOST=$MANAGER_IP -e PORT=5000 -v /var/run/docker.sock:/var/run/docker.sock manomarks/visualizer

# join the swarm
eval $(docker-machine env swarm-db-worker)
docker swarm join --token $token_worker $MANAGER_IP:2377

eval $(docker-machine env swarm-idp-worker)
docker swarm join --token $token_worker $MANAGER_IP:2377

eval $(docker-machine env swarm-index-worker)
docker swarm join --token $token_worker $MANAGER_IP:2377

eval $(docker-machine env swarm-front-end-worker)
docker swarm join --token $token_worker $MANAGER_IP:2377

eval $(docker-machine env swarm-data-node-worker)
docker swarm join --token $token_worker $MANAGER_IP:2377

# create overlay network
eval $(docker-machine env swarm-manager)
docker network create -d overlay swarm-network

# assign functional labels to nodes
eval $(docker-machine env swarm-manager)
docker node update --label-add esgf_type=db swarm-db-worker
docker node update --label-add esgf_type=idp swarm-idp-worker
docker node update --label-add esgf_type=index swarm-index-worker
docker node update --label-add esgf_type=front-end swarm-front-end-worker
docker node update --label-add esgf_type=data-node swarm-data-node-worker
