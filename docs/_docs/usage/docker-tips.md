---
title: Docker Tips
category: Usage
order: 1.5
---

The following page gives some useful tips on docker and swarm managment.
Docker version 17.09.0-ce, build afdb6d4

## Docker container managment

* List the running containers
```sh
docker ps
```

* List all the containers (including the stopped ones)
```sh
docker ps -a
```

* Stop all running containers
```sh
docker ps | xargs docker stop
```

* Delete all the containers (must be stopped before)
```sh
docker ps -aq | xargs docker rm --force
```

* Inspect/connect to a running container thanks to its ID (ex: 67e4c31da0ee ; get the container ID from the docker ps command)
```sh
docker exec -it 67e4c31da0ee bash
```

## Docker volume managment

* List the volumes
```sh
docker volume ls
```

* Remove dangling volumes of container
```sh
docker volume ls -f "dangling=true" | xargs docker volume rm 
```

* Remove all volumes
```sh
docker volume ls -q | xargs docker volume rm --force
```

## Docker image managment

* List the images
```sh
docker image ls # or docker images
```

* Remove dangling images
```sh
docker image ls -f "dangling=true" | xargs docker image rm 
```

* Remove all images
```sh
docker image ls -q | xargs docker image rm --force
```

* Remove image according to a given pattern (ex: the images tagged esgfhub devel)
```sh
docker images "esgfhub/*:devel" -q | xargs docker image rm
```

* Remove images tagged "<none>"
```sh
docker image ls | grep "^<none>" | awk '{print $3}' | xargs docker image rm --force
```

* Inspect/connect to an image (ex: esgfhub/esgf-httpd:devel image)
```sh
docker run --rm -it --entrypoint=/bin/bash esgfhub/esgf-httpd:devel
```