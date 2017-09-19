***************************************
Architecture and Development Guidelines
***************************************

The design and development of the ESGF/Docker services should conform
(whenever possible) to the following guidelines.

Image Hierarchy
===============

ESGF images are built in a hierarchy structure where common libraries,
tools and functionality are factored in a parent image, from which more
specific images are derived. This design has several benefits: 

* All images run the same version of the core OS, libraries and engines such
  as Centos, Java, Python, SSL, Tomcat, etc. 
* It's easy to propagate updates of any of these components to all images. 
* Common building instructions are not repeated, in different form, in different Dockerfiles.

The current version of the ESGF image hierarchy is shown in the figure below.

Image Content
=============

For maximum flexibility, and conforming to the "micro-services"
architecture, each ESGF image should contain only one service,
interacting with the other ESGF services through publicly exposed
endpoints. In some cases though a set of services must be co-located as
they cannot function without each other, in which case they should be
built into the same image (see for example the esgf-data-node image).

Image Versioning
================

*Insert content from Sebastien G. proposal.*

Directory Structure
===================

In order to promote conformity and easy of development, each ESGF/Docker
image should be built from a directory that conforms to the following
directory structure:

*  *Dockerfile* : Docker build file
*  *conf/* : image configuration files (for supervisor or the application)
*  *scripts/* : scripts necessary to perform initialization of other
   application tasks (for example, create a Solr shard)

Deployment files that span several services, such as docker-compose and
docker-stack files, are (for now) stored in the top-level directory of
this repository.

Supervisor
==========

ESGF images should use the Python program "Supervisor" to start and
monitor services inside a Docker container. Benefits of using Supervisor
include: 

* Common instructions for starting/stopping/restarting each
  service from inside each container. 
* Ability to add services to the
  startup pool by simply dropping configuration files in a standard location. 
* Ability to start/stop/restart entire group of services (for example, all Solr shards at once). 
* Ability to start services as non-privileged users such as "tomcat", "apache", etc.

Container Initialization
========================

In some cases, it is necessary to execute some initialization tasks when
a container first start, or when it is re-started. In this case, the
container services should be started through a docker-entrypoint.sh
script which: 

* First performs all required initialization. 
* Then starts Supervisor in non-daemon mode (to keep the container running).

Site-Specific Configuration
===========================

ESGF/Docker images must not contain any site-specific files or
configuration, such as SSL certificates, hostnames, passwords etc. At
this time, all site-specific configuration is stored in a directory tree
rooted at $ESGF_CONFIG/, which is cross-mounted as a shared volume on
on all containers. In the future, the site-specific configuration might
be "pushed" to the containers via other means.

Persistent Data
===============

ESGF services access data that must be persisted across container
restarts or upgrades. Examples of these data include:

*  Postgres database content
*  TDS catalogs
*  Solr indexes
*  CoG site media

These data must either be located on shared host directories that are
cross-mounted to all containers, or inside named data volumes (which are
managed by Docker outside of the container lifecycle). They can not be
located inside the Docker containers as they would be lost during
upgrades.
