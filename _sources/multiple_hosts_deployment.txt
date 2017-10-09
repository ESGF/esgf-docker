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

*Tested with $ESGF_VERSION=1.3*.

Pre-Requisites
==============

A Docker Swarm composed of 1 or more nodes. See specific instructions on
how to set this up on :ref:`a single MacOSX laptop <docker_swarm_setup_on_macosx>`, on the Amazon Cloud, or an
internal Linux cluster.

Setup
=====

Follow the same setup steps as for the :ref:`single_host_deployment`, namely:

*  Checkout the source code from this GitHub repository, on some
   location on the Swarm manager node. Use the *master* branch.
*  Define the environmental variables $ESGF_HOSTNAME, $ESGF_CONFIG,
   $ESGF_VERSION and $ESGF_DATA_DIR. 
*  Initialize the ESGF node configuration: ./esgf_node_init.sh

Please note that at this time, the $ESGF_CONFIG directory tree containing the site specific configuration
needs to be available to **all** swarm nodes - either cross mounted from a shared disk, or pushed to all VMs.

Note also that in this particular architecture, even if the ESGF services are
deployed across multiple hosts, they all share the same SSL certificate
(cross-mounted from a shared volume), and they are all reachable at the
hostname $ESGF_HOSTNAME: this is because the Docker Swarm routing mesh
always directs client requests sent to $ESGF_HOSTNAME to the proper
container(s) where the specific services are deployed.

Execution
=========

*  Assign metadata tags to the Swarm nodes to define where the specific
   ESGF services will be deployed. For example, on a Swarm cluster of 3
   nodes, the following tags could be assigned::

      eval $(docker-machine env node1)
      docker node update --label-add esgf_front_node=true node1
      docker node update --label-add esgf_db_node=true node1
      docker node update --label-add esgf_idp_node=true node1
      docker node update --label-add esgf_index_node=true node2
      docker node update --label-add esgf_solr_node=true node2
      docker node update --label-add esgf_data_node=true node3

   Or, on a Swarm of 6 nodes, each label can be assigned to a different node 
   (as shown in the :ref:`single MacOSX laptop instructions <docker_swarm_setup_on_macosx>`).

*  From the source code directory on the Swarm manager node, issue the
   following command to deploy the stack of ESGF services, then wait for
   the services to be ready (which the first time might take up to 20
   minutes, depending on your internet connection speed, 
   since several large images need to be downloaded to the various nodes in the Swarm)::

      eval $(docker-machine env node1)
      docker stack deploy -c docker-stack.yml esgf-stack
      docker service ls

*  When all services are deployed, execute the tests described in the :ref:`testing_guide`.

*  Clean up: remove the full ESGF stack from the Swarm, and delete the networks::

     eval $(docker-machine env node1)
     docker stack rm esgf-stack
     docker network rm esgf-stack_dbnetwork  esgf-stack_default

