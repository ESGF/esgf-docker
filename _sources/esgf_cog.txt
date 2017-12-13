***************
esgf-cog Image
***************

This document contains miscellaneous details on how the *esgf-cog* Docker container is configured and operated.

In the following, the environment variable *ESGF_VERSION* must be set to the desired image version, for example::

  export ESGF_VERSION=latest

Starting the container
======================

To pre-download the CoG image::

  docker pull esgfhub/esgf-cog:${ESGF_VERSION}

To start the container standalone::

  docker run -ti -p 8000:8000 --name cog esgfhub/esgf-cog:${ESGF_VERSION}

* will run CoG through the Django development server, running on port 8000
* will use hostname=localhost
* will skip ESGF setup, i.e. it will use a sqllite database (not the ESGF postgres database), and will not install any ESGF configuration files
* CoG will be accessible at the URL: http://localhost:8000/
* will need to login at the URL: http://localhost:8000/login2/ with the default username ("rootAdmin") and password ("changeit")

To start the container standalone, but using a specific hostname::

  docker run -ti -p 8000:8000 --name cog -e ESGF_HOSTNAME=${ESGF_HOSTNAME} esgfhub/esgf-cog:${ESGF_VERSION} ${ESGF_HOSTNAME} false true

* CoG will be accessible at the URL: http://${ESG_HOSTNAME}:8000/

To start the container standalone, but using source code from a local directory, for development purposes::

  docker run -ti -p 8000:8000 --name cog -v ${COG_INSTALL_DIR}:/usr/local/cog/cog_install esgfhub/esgf-cog:${ESGF_VERSION}

* for example ${COG_INSTALL_DIR}=/Users/cinquini/Documents/workspace/cog
* will again use hostname=localhost
* will again run CoG through the Django server

To run CoG as part of the ESGF software stack, with postgres database and Apache front-end::

  # initialize the $ESGF_CONFIG directory containing all ESGF node configuration
  cd .../esgf-docker
  scripts/esgf_node_init.sh

  # start CoG and its dependency containers
  docker-compose up esgf-cog esgf-postgres esgf-httpd

* will run CoG within the Apache httpd server (and container) through mod_wsgi
* the cog container is kept running as a data container, exposing the CoG source directory *COG_INSTALL_DIR=/usr/local/cog/cog_install* to the httpd container

After the first startup, the containers can be restarted without re-initializing them as such::

  export INIT=false
  docker-compose up -d esgf-postgres
  docker-compose up esgf-cog esgf-httpd

To run the full ESGF software stack::
  
  cd .../esgf-docker
  docker-compose up
