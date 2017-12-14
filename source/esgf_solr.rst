***************
esgf-solr Image
***************

This document contains miscellaneous details on how the *esgf-solr* Docker container is configured and operated.

Starting the container
======================

To start the container standalone::

  docker run -ti -p 8983:8983 -p 8984:8984 --name esgf-solr esgfhub/esgf-solr:${ESGF_VERSION}

To start the container using an existing pre-populated index::
  
  docker run -ti -p 8983:8983 -p 8984:8984 --name esgf-solr -v ${SOLR_INDEX_DIR}:/esg/solr-index  esgfhub/esgf-solr:${ESGF_VERSION}

where the *SOLR_INDEX_DIR* directory must contain the master and slave indexes::

  ls -l $SOLR_INDEX_DIR
  master-8984
  slave-8983

To start the container using docker-compose::

  docker-compose -f docker-stack.yml up esgf-solr

To start the container as part of the whole ESGF stack::

  docker stack -c docker-stack.yml esgf-stack


Testing
=======

The following URLs can be used to test that the individual shards are working correctly:

* Solr admin interface:

  * master shard: http://localhost:8984/solr
  * slave shard http://localhost:8983/solr

* Solr queries (for datasets):

  * master shard: http://localhost:8984/solr/datasets/select?q=*%3A*&wt=json&indent=true
  * slave  shard: http://localhost:8983/solr/datasets/select?q=*%3A*&wt=json&indent=true


Important Files and Directories
===============================

* Shard configuration directory: */usr/local/solr-home/<shard>*
* Shard index: */esg/solr-index/<shard>*
* Server log files: */usr/local/solr/server/logs/*
* The log file level can be configured in file: */usr/local/solr/server/resources/log4j.properties*
* Supervisor configuration directory: */etc/supervisor/conf.d/*
* To start a shard with more memory, there are two options:

   * change the value of the option "-m 512m" in the supervisor startup file for that shard (for example: */etc/supervisor/conf.d/supervisord.solr_master_8984.conf*)
   * or change the value of SOLR_HEAP in the shard-specific envirnment file referenced by SOLR_INCLUDE (for example: */usr/local/solr-home/master-8984/solr.in.sh*)

  Note that the first option (specified when the shard is started) will override the second option.
     
Starting/Stopping Solr shards
=============================

Once the container is running, you can enter the container to start/stop any single shard, or all shards at the same time::

   docker exec -it <container_id> /bin/bash
   supervisorctl start/stop/restart solr:master_8984
   supervisorctl start/stop/restart solr:slave_8983
   supervisorctl start/stop/restart solr:*
   

Adding/Removing a shard
=======================

To add a new shard that replicates data from the JPL index node::

   # enter the container
   docker exec -it <container_id> /bin/bash

   # deploy the configuration for the new shard
   cd /usr/local/bin
   ./add_shard.sh esgf-node.jpl.nasa.gov 8985

   # load the configuration into supervisor and start the service
   supervisorctl update
   supervisorctl restart solr:esgf-node.jpl.nasa.gov_8985

The instructions above will perform the following actions:

* Deploy a new shard configuration home under */usr/local/solr-home/esgf-node.jpl.nasa.gov-8985*
* Create an empty shard index under */esg/solr-index/esgf-node.jpl.nasa.gov-8985*
* Insert the new shard into the shared list of shards to be queried (to be used by the *esgf-index-node* container): */esg/config/esgf_shards_static.xml*
* Create a new service configuration to be used by Supervisor: */etc/supervisor/conf.d/supervisord.solr_esgf-node.jpl.nasa.gov_8985.conf*

The new shard will start replicating the JPL index node within the configured time interval (currently, 60 min). To start replicating right away, issue the following commands::

   curl 'http://localhost:8985/solr/datasets/replication?command=fetchindex'
   curl 'http://localhost:8985/solr/files/replication?command=fetchindex'
   curl 'http://localhost:8985/solr/aggregations/replication?command=fetchindex'

Note that port 8985 (and any other additional shard port) is not exposed by default by the container, so it can only be queried from within the container.

To remove the shard follow this procedure::

   # delete the shard
   cd /usr/local/bin
   ./remove_shard.sh esgf-node.jpl.nasa.gov 8985

   # restart supervisor with the new configuration:
   supervisorctl update

The instructions above will revert the actions taken when the shard was created.
