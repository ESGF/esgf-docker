---
title: Quick Start
category: Usage
order: 1
---

This page describes the steps required to launch a single-node local test instance
using self-signed certificates.

## Pre-requisites

The only pre-requisites are a recent version of Docker Engine and Docker Compose
on the host system.

## Configure environment

First, clone the repository:

```sh
git clone https://github.com/cedadev/esgf-docker.git
cd esgf-docker
```

A single-node test installation requires two environment variables to be set:

```sh
$ export ESGF_HOSTNAME=local.esgf.org
$ export ESGF_CONFIG=/path/to/empty/config/directory
```

The hostname should be a DNS name pointing to the current machine, or the IP
address of the current machine. However, because the containers make HTTP calls
to `ESGF_HOSTNAME`, it **cannot** be `localhost`, `127.0.0.1` or any DNS name that
has been configured to resolve to `127.0.0.1`, as that would cause the container
to try to contact itself.

<div class="note note-info" markdown="1">
To find out the IP addresses of the current machine, use either `ifconfig` or `ip addr`
depending on which command is available.

If you prefer to use a domain rather than an IP, you can create a mapping on the
local machine by adding an entry to `/etc/hosts` on Linux, or `/private/etc/hosts`
on Mac.
</div>

<div class="note note-warning" markdown="1">
On a Mac, the Docker daemon can only mount files in your home directory into containers.
This means you need to make sure that the `ESGF_CONFIG` directory is in your
home directory.
</div>

## Generate configuration

Once you have exported the environment variables, run the following commands to
generate deployment secrets, self-signed certificates and certificate bundles in
the various required formats:

```sh
$ docker run -v "$ESGF_CONFIG":/esg -e ESGF_HOSTNAME cedadev/esgf-setup generate-secrets
$ docker run -v "$ESGF_CONFIG":/esg -e ESGF_HOSTNAME cedadev/esgf-setup generate-test-certificates
$ docker run -v "$ESGF_CONFIG":/esg -e ESGF_HOSTNAME cedadev/esgf-setup create-trust-bundles
```

## Launch containers

After generating the configuration, you are ready to launch the containers using
Docker Compose:

```sh
$ docker-compose up -d
```

This will pull all the images from Docker Hub (unless they are already available
locally) and launch the containers in order.

Once all the containers are running normally, navigate to `https://$ESGF_HOSTNAME`
in a browser and you should see the CoG interface.

Try to log in with the OpenID `https://$ESGF_HOSTNAME/esgf-idp/openid/rootAdmin`.
To find the `rootAdmin` password that was randomly generated for you, run the
following command:

```sh
echo "$(cat "$ESGF_CONFIG/secrets/rootadmin-password")"
```

## Stopping containers

To stop the containers:

```sh
$ docker-compose stop
```

To remove all the containers and associated data volumes:

```sh
$ docker-compose down -v
```
