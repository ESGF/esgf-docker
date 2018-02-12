.. _docker_tips:

***********
Docker Tips
***********

Abstract
========

The following page gives some useful tips on docker and swarm managment

Version
=======

*  Docker version 17.09.0-ce, build afdb6d4

Docker container managment
==========================

List the running containers::

  docker ps

List all the containers (including the stopped ones)::

  docker ps -a

Remove all the container (running or not)::

  docker ps -aq | xargs docker rm --force
  
Inspect/connect to a running container (ex: 67e4c31da0ee)::

  # Get the container ID from the docker ps command.
  docker exec -it 67e4c31da0ee bash

Docker volume managment
=======================

List the volumes::

  docker volume ls

Remove dangling volumes of container::

  docker volume ls -f "dangling=true" | xargs docker volume rm 

Remove all volumes::

  docker volume ls -q | xargs docker volume rm --force


Docker image managment
======================

List the images::

  docker image ls # or docker images

Remove dangling images::

  docker image ls -f "dangling=true" | xargs docker image rm 

Remove all images::

  docker image ls -q | xargs docker image rm --force

Remove image according to a given pattern (ex: the esgfhub devel images)::

  docker images "esgfhub/*:devel" -q | xargs docker image rm

Remove images tagged "<none>"::

  docker image ls | grep "^<none>" | awk '{print $3}' | xargs docker image rm --force

Inspect/connect to an image (ex: esgfhub/esgf-httpd:devel image)::

  docker run --rm -it --entrypoint=/bin/bash esgfhub/esgf-httpd:devel