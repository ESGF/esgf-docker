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


Docker volume managment
=======================

Remove dangling volumes of container::

  docker volume ls -f "dangling=true" | xargs docker volume rm 

Remove all volumes::

  docker volume ls -q | xargs docker volume rm --force


Docker image managment
======================

Remove dangling images::

  docker image ls -f "dangling=true" | xargs docker image rm 

Remove all volumes::

  docker image ls -q | xargs docker volume rm --force

Remove image according to a given pattern::

  docker images "esgfhub/*:devel" -q | xargs docker image rm