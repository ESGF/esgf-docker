*************************
Multiple Hosts Deployment
*************************

Abstract
========

These instructions explain how to deploy the ESGF software stack as a
set of interacting Docker containers deployed on a cluster of Swarm
nodes. Which ESGF services/containers are deployed onto which nodes is
determined by placement constraints defined by node metadata tags. A
single physical node can host services of one or more types, if the
appropriate metadata tags are set for that node.

Version
=======

These instructions were tested with ESGF\_VERSION=1.2

Pre-Requisites
==============

A Docker Swarm composed of 1 or more nodes. See specific instructions on
how to set this up on a single MacOSX laptop, on the Amazon Cloud, or an
internal Linux cluster.

Setup
=====

Follow the same setup steps as for the single host deployment, namely:

-  Checkout the source code from this GitHub repository, on some
   location on the Swarm manager node.
-  Define the environmental variables ESGF\_HOSTNAME, ESGF\_CONFIG,
   ESGF\_VERSION and ESGF\_DATA\_DIR.
-  Initialize the ESGF node configuration: ./esgf\_node\_init.sh

Note that in this particular architecture, even if the ESGF services are
deployed across multiple hosts, they all share the same SSL certificate
(cross-mounted from a shared volume), and they are all reachable at the
hostname $ESGF\_HOSTNAME: this is because the Docker Swarm routing mesh
always directs client requests sent to $ESGF\_HOSTNAME to the proper
container(s) where the specific services are deployed.

Execution
=========

-  Assign metadata tags to the Swarm nodes to define where the specific
   ESGF services will be deployed. For example, on a Swarm cluster of 3
   nodes, the following tags could be assigned:

-  docker node update --label-add esgf\_front\_node=true node1
-  docker node update --label-add esgf\_db\_node=true node1
-  docker node update --label-add esgf\_idp\_node=true node1
-  docker node update --label-add esgf\_index\_node=true node2
-  docker node update --label-add esgf\_solr\_node=true node2
-  docker node update --label-add esgf\_data\_node=true node3

-  From the source code directory on the Swarm manager node, issue the
   following command to deploy the stack of ESGF services, then wait for
   the services to be ready (which the first time might take several
   minutes, since several large images need to be downloaded to the
   various nodes in the Swarm):
-  docker stack deploy -c docker-stack.yml esgf-stack
-  docker service ls

-  When all services are deployed, test the following URLs, replacing
   "my-node.esgf.org" with your value of $ESGF\_HOSTNAME:
-  Docker visualizer tool: http://my-node.esgf.org:8080/
-  Solr admin interface: https://my-node.esgf.org/solr/#/
-  ESGF search API: http://my-node.esgf.org/esg-search/search
-  ESGF IdP: https://my-node.esgf.org/esgf-idp/
-  CoG home project: https://my-node.esgf.org/projects/testproject/

   -  The first time, login with
      openid=https://my-node.esgf.org/esgf-idp/openid/rootAdmin and
      password=changeit

-  TDS: https://my-node.esgf.org/thredds
-  ORP: https://my-node.esgf.org/esg-orp/
-  SLCS: https://my-node.esgf.org/slcs/admin/

-  Clean up: remove the full ESGF stack from the Swarm:
-  docker stack rm esgf-stack
