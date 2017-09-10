**********************
Single Host Deployment
**********************

*Tested with ESGF_VERSION=1.1*

Abstract
========

The following instructions explain how to run an ESGF node as a set of
interacting Docker containers on a single host (for example, a Linux VM,
a MacOSX laptop, etc.). Docker Engine must be up and running before
proceeding.

Pre-Requisites
==============

*  A host system with the latest version of Docker Engine installed (at
   this time, Docker 1.12+). Tested on MacOSX and Linux CentOS.
*  Java SDK (at this time 1.8), keytool is required.
.. *  Docker-compose (at this time 1.14.0), installation procedure
   `here <https://docs.docker.com/compose/install/#install-compose>`__

Setup
=====

*  Clone the current repository, cd to the top-level directory. Checkout
   the latest stable branch, which is named "vN.M" (for example, "v1.1"). ::

     git clone https://github.com/ESGF/esgf-docker.git
     cd esgf-docker
     git tag -l
     git checkout vN.M

   Note: if you want to create a new branch based on a tag, use the command::

     git checkout tags/<tag_name> -b <branch_name>

*  Define your environment:

   *  **ESGF_HOSTNAME** must reference the Fully Qualified Domain Name of the host where the containers will be running:

     * on linux, use the actual server host name::

        export ESGF_HOSTNAME=`hostname`

     * on mac, choose a custom host name, and bind it to the current IP address of the Mac, for example::

          export ESGF_HOSTNAME=my-node.esgf.org

       You must edit */private/etc/hosts* and map *my-node.esgf.org* to the current Mac IP address
       (which you can find from the Control Panel Network Settings), for example::

          cat /private/etc/hosts
          ...
          192.168.0.5 my-node.esgf.org

     *  on mac using docker-machine:
     
        * set ESGF_HOSTNAME, for example::
         
            export ESGF_HOSTNAME=my-esgf-node
        
        * create a docker-machine with a name that matches a chosen ESGF_HOSTNAME, for example::
        
            docker-machine create --driver virtualbox --virtualbox-memory=4096 --virtualbox-cpu-count=2 my-esgf-node
          
        * determine the IP address of the new docker-machine::
   
            docker-machine ip my-esgf-node
          
        * edit */private/etc/hosts* and map *my-esgf-node* to the docker-machine IP address, e.g.::
        
            cat /private/etc/hosts
            ...
            192.168.99.101  my-esgf-node
          
        * make sure to run::
        
            eval $(docker-machine env my-esgf-node)
            
          to ensure your docker commands use the new docker-machine and not the default.

   * **ESGF_CONFIG** must reference a directory on the host system that will store 
     all the site-specific configuration, e.g.::

       export ESGF_CONFIG=~/esgf_config
       mkdir -p $ESGF_CONFIG

   * **ESGF_DATA_DIR** must reference the root of the data directory on your host.

     * for example on linux::
      
         export ESGF_DATA_DIR=/esgf/data
         
     * for example on mac::
        
         export ESGF_DATA_DIR=~/esgf_data 
         
       (since on a mac the Docker engine only has access to the filesystem under the user home directory).
       
     Then create the directory if not existing already::
     
       mkdir -p $ESGF_DATA_DIR

   * **ESGF_VERSION** is the version of the ESGF/Docker stack to be used, 
     which is recommended to be the latest stable version, e.g.::

       export ESGF_VERSION=1.1

* Initialize your node configuration: create a self-signed certificate 
  for $ESGF_HOSTNAME and populate the $ESGF_CONFIG directory with initial content. From the scripts/ directory::
    
    ./esgf_node_init.sh
    ls -l $ESGF_CONFIG

  Note: if you are going through these instructions more than one time, 
  make sure you don't have previous containers that were configured with a different version of the certificates. 
  So before re-initializing the node, make sure to stop all running containers. It might be also useful to remove all previously created volumes. From
  the top-level *esgf-docker/* directory, issue the commands::

    docker-compose down 
    docker rm $(docker ps -a -q)
    docker volume ls -qf dangling=true | xargs docker volume rm

  Note: it's been observed that the Docker engine on a mac might not track time correctly 
  if the mac goes into sleep mode, which may cause problems with the validity of the certificates. 
  To bypass this issue, restart the Docker engine after generating the certificates.

Execution
=========

*  Optional: pre-download the latest version of all ESGF Docker images.
   If not done now, the images will be pulled down automatically one by
   one when each service is started. Note that downloading or
   pre-downloading all the images (which amount to several GBs) may take
   a considerable time, depending on your internet connection. From the *scripts/* directory::
   
     ./docker_pull_all.sh $ESGF_VERSION

*  Start all ESGF services in daemon mode, then look at the combined
   logs. Even if the images have been pre-download, starting all the
   services the first time may take a few minutes as the host system is
   allocating memory, disk space, and initializing each service.
   
   * if you have pre-downloaded the images, issue::
     
       docker images 
     
     to make sure the version of the images matches what you expect from $ESGF_VERSION
 
   * from the top-level *esgf-docker/* directory::

       docker-compose up -d
       docker-compose logs -f
       docker ps

*  Do some testing. Note that you will have to instruct your browser to
   trust the self-signed certificate from $ESGF_HOSTNAME.
   
   * In a browser, access the top-level CoG page for the node::
   
        https://$ESGF_HOSTNAME/
     
   * Login with the *rootAdmin* openid::

        https://$ESGF_HOSTNAME/esgf-idp/openid/rootAdmin
   
     and use the password: *changeit* .
   
   * Access the top-level TDS catalog::
    
        http://$ESGF_HOSTNAME/thredds
        
   * Download one of the test files. 
     You will have to log onto the ORP with the same openid as above.

* Change the ESGF root password. You must first stop the containers,
  then run a script that picks up the new password from an environment
  variable. This must be done after the containers have been started at
  least once, because the initial default password is hard-coded into the postgres image.
  
  * From the top-level *esgf-docker/* directory::
   
      docker-compose stop
      
  * For example, set the new password to::
  
      export ESGF_PASSWORD=abc123
      
  * From the *scripts/* directory:: 
  
      ./change_password.sh
      
  * Restart the ESGF services to make sure everything still works::
  
      docker-compose up -d
 
    Note that the above operation will change the ESGF password for all
    modules, except for the password used by the *rootAdmin* openid to log
    onto the web (this is by design, so that the two passwords can be
    different). This last password can be changed through the CoG
    interface once *rootAdmin* is logged in.

  * Stop all services, and optionally remove all containers and associated data volumes::
  
      docker-compose stop
      # optional: 
      docker-compose down
      # optional: 
      docker volume ls -qf dangling=true \| xargs docker volume rm
