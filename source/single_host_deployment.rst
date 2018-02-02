.. _single_host_deployment:

**********************
Single Host Deployment
**********************

*Tested with ESGF_VERSION=1.4*

Abstract
========

The following instructions explain how to run an ESGF node as a set of
interacting Docker containers on a single host (for example, a Linux VM,
a MacOSX laptop, etc.). Docker Engine must be up and running before
proceeding.

Pre-Requisites
==============

*  A host system with the latest version of Docker Engine installed (at
   this time, Docker 1.17.x). Tested on MacOSX (Version 17.09.1-ce-mac42) and Linux CentOS.
*  Java SDK (at this time 1.8), keytool is required (add it to the PATH var env).
*  Docker Compose (at this time 1.17.x), installation procedure
   `here <https://docs.docker.com/compose/install/#install-compose>`__
   (on a Mac, Compose is automatically installed as part of the standard Docker installation).
   
Cleanup
=======

If you are following these instructions *not* for the first time,
it might be a good idea to completely reset the system so you can start from a clean slate. To do so,
stop all running containers, and remove all data volumes and all configuration.
Make sure that the environment ESGF_CONFIG is set to your previously chosen value, for example::
   
    export ESGF_CONFIG=~/esgf_config

Then, from the top-level *esgf-docker/* directory, issue the commands::

    docker-compose down
    docker rm $(docker ps -a -q)
    docker volume ls -qf dangling=true | xargs docker volume rm
    rm -rf $ESGF_CONFIG/*


Setup
=====

*  Clone the current repository, cd to the top-level directory. Checkout
   the master branch, which is the latest stable branch::

     git clone https://github.com/ESGF/esgf-docker.git
     cd esgf-docker
     git checkout master

*  Define your environment. Note that on a Mac the Docker engine has access only to the filesystem under the user home directory,
   so all environment variables that reference directories must use paths under the user home directory.

   * Add the path to the keytool install directory::
   
       export PATH='/path/to/keytool/install/dir':$PATH
       which keytool
   
   *  **ESGF_HOSTNAME** must reference the Fully Qualified Domain Name of the host where the containers will be running:

     * On linux, use the actual server host name::

        export ESGF_HOSTNAME=`hostname`

     * On mac, choose a custom host name, and bind it to the current IP address of the Mac, for example::

          export ESGF_HOSTNAME=my-node.esgf.org
          echo $ESGF_HOSTNAME 

       You must edit */private/etc/hosts* and map *my-node.esgf.org* to the current Mac IP address
       (which you can find from the Control Panel Network Settings), for example::

          cat /private/etc/hosts
          ...
          192.168.0.5 my-node.esgf.org

   * **ESGF_CONFIG** must reference a directory on the host system that will store 
     all the site-specific configuration, e.g.::

       export ESGF_CONFIG=~/esgf_config
       mkdir -p $ESGF_CONFIG

   * **ESGF_VERSION** must specify the version of the ESGF/Docker stack to be used,
     which is recommended to be the latest stable version, e.g.::

       export ESGF_VERSION=1.4

   * **ESGF_IMAGES_HUB** must reference the name of the Docker repository to pull the images from, which for this
     exercise should be *esgfhub*::

       export ESGF_IMAGES_HUB=esgfhub

   * **ESGF_DATA_DIR** must reference the root of the data directory on your host.

     * for example on linux::
      
         export ESGF_DATA_DIR=/esgf/data
         
     * for example on mac::
        
         export ESGF_DATA_DIR=~/esgf_data 
         
       
     Then create the directory if not existing already::
     
       mkdir -p $ESGF_DATA_DIR

     Note that this location is currently not really used to store any data.


* Initialize your node configuration: create a self-signed certificate 
  for $ESGF_HOSTNAME and populate the $ESGF_CONFIG directory with initial content::
  
  Note: if you are on a Mac, ensure **gtar** and **xz** utilities are installed before running the :code:`esgf_node_init.sh` script::
    
    ./scripts/esgf_node_init.sh
    ls -l $ESGF_CONFIG

  Note: it's been observed that the Docker engine on a mac might not track time correctly 
  if the mac goes into sleep mode, which may cause problems with the validity of the certificates. 
  To bypass this issue, restart the Docker engine after generating the certificates.

Execution
=========

*  Optional: pre-download the latest version of all ESGF Docker images.
   If not done now, the images will be pulled down automatically one by
   one when each service is started. Note that downloading or
   pre-downloading all the images (which amount to several GBs) may take
   a considerable time, depending on your internet connection.::
   
     ./scripts/docker_pull_all.sh $ESGF_VERSION
     docker images | grep $ESGF_VERSION

   Make sure the hash of each image is what you would expect from the $ESGF_VERSION you are using.

*  Start all ESGF services in daemon mode, then look at the combined
   logs. Even if the images have been pre-download, starting all the
   services the first time may take a few minutes as the host system is
   allocating memory, disk space, and initializing each service.
   From the top-level *esgf-docker/* directory::

       docker-compose up -d
       docker-compose logs -f
       # in another terminal:
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

   * Re-initialize the TDS catalogs::

        https://$ESGF_HOSTNAME/thredds/admin/debug?Catalogs/reinit

     Use username = *dnode_user* and password = *changeit* .
        
   * Download one of the test files. 
     You will have to log onto the ORP with the same openid as above.

   * Test the Solr admin interface::

        https://$ESGF_HOSTNAME/solr

* **NOTE: changing password not currently working in ESGF_VERSION=1.4: will be fixed in ESGF_VERSION=1.5.**
  
  Change the ESGF root password. You must first stop the containers,
  then run a script that picks up the new password from an environment
  variable. This must be done after the containers have been started at
  least once, because the initial default password is hard-coded into the postgres image.
  
  * From the top-level *esgf-docker/* directory::
   
      docker-compose stop
      
  * For example, set the new password to::
  
      export ESGF_PASSWORD=abc123
      
  * Change the password:: 
  
      ./scripts/change_password.sh
      
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
