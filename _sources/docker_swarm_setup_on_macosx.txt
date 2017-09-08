***************************
Docker Swam Setup on MacOSX
***************************

Abstract
========

This page instructs on how to setup a Docker Swarm on a single MacOSX
system. This Swarm can be effectively used as a test environment for
deploying ESGF software stack on a multiple-host cluster.

Execution
=========

-  Use Docker to create a cluster of N Virtual Machines, for example
   N=6:
-  docker-machine create --driver virtualbox node1
-  docker-machine create --driver virtualbox node2
-  docker-machine create --driver virtualbox node3
-  docker-machine create --driver virtualbox node4
-  docker-machine create --driver virtualbox node5
-  docker-machine create --driver virtualbox node6

-  List the VMs to identify their IP addresses:
-  docker-machine ls

-  Select one of the nodes to be the Swarm leader, "connect" to it, and
   initialize the Swarm, using its IP address (in what follows, we use
   IP\_MANAGER\_ADDRESS=192.168.99.100). Save the output of the last
   command, since it will be needed on the other nodes to join the
   swarm.
-  eval $(docker-machine env node1)
-  docker swarm init --advertise-addr 192.168.99.100

-  Make the other VMs join the swarm, one at a time. For example, on
   node2:
-  eval $(docker-machine env node2)
-  docker swarm join --token
   SWMTKN-1-0di7dn7qutbknirl9zrx2dodxwz7mj7ax708cf6fjtslorsypb-3fp4nrsg79ufrcxna93yk4l8o
   192.168.99.100:2377

Replace the last command with the output from the "docker swarm init..."
command issued on the Swarm manager. Repeat this process on Worker nodes
in the Swarm. Finally, list all nodes in the Swarm: \* docker node ls

-  Back on the Swarm manager, assign metadata tags to all nodes in the
   Swarm to define where the different ESGF container/services will be
   placed. For example, on a 6-nodes Swarm:
-  eval $(docker-machine env node1)
-  docker node update --label-add esgf\_front\_node=true node1
-  docker node update --label-add esgf\_db\_node=true node2
-  docker node update --label-add esgf\_index\_node=true node3
-  docker node update --label-add esgf\_idp\_node=true node4
-  docker node update --label-add esgf\_data\_node=true node5
-  docker node update --label-add esgf\_solr\_node=true node6

-  Associate the IP address of the Swarm manager node to the hostname
   you intend to use to access the ESGF services (for example,
   ESGF\_HOSTNAME=my-node.esgf.org):
-  sudo vi /private/etc/hosts
-  192.168.99.100 my-node.esgf.org

Note that because of the Docker Swarm routing mesh capability, the IP
address above can be that of any node in the Swarm, and that URLs
starting with http(s)://my-node.esgf.org/... can be used to access any
of the ESGF services in the stack, no matter on which node they are
deployed.
