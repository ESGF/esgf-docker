---
title: Comparison to original implementation
category: Developers
order: 4
---

This project represents a significant reworking of the original implementation
of ESGF Docker. This article attempts to describe the most significant changes,
and the rationale behind them.

## Removal of supervisor

In the original implementation of ESGF Docker, every container included the
[Supervisor process control system](http://supervisord.org/). It was used to
manage the application processes inside the container, including restarting
failed processes.

Containers are intended to run a single command until it exits, using the exit
code of the command to determine whether the container failed or not. In the case
of a container providing a long-running process, such as a web-server, the
command typically will never exit unless there is a failure. Container runtimes,
of which Docker is just one, are designed to be able to restart failed containers,
which means the use of a process control system in a container is unnecessary.

In fact, not only is it unnecessary, but it can actually mask problems - because
the supervisor process never exits even when the application process has failed,
the container appears healthy when running `docker ps`.

## Self-contained applications

The original implementation of ESGF Docker had several containers that initialised
shared volumes before exiting, with other containers running those applications.
One example of this was the CoG, where the `esgf-cog` container populated a Python
virtual environment which was then used by `esgf-httpd` to run a `mod_wsgi`
application. `esgf-httpd` was responsible for running multiple applications in
this way.

While so-called "init-containers" are not always bad, running multiple applications
in a container is not normally advisable. It is better practice to have each
application capable of running itself from scratch. This has particular benefits
when using a cluster with a container orchestration system, such as Kubernetes,
as it means:

  1. A single badly-behaving application only affects itself. In the original ESGF
     Docker implementation, a badly behaving CoG could take down the whole HTTPD
     container (and hence effectively shut down the whole node!).
  1. Each application can be scaled out independently if required.

With this implementation of ESGF Docker, each Tomcat and Django application runs
entirely in its own container. The `esgf-httpd` container has been replaced with
a pure-HTTP proxy using Nginx. When deployed using Kubernetes, the proxy will not
be used at all, with each application managing its own
[Ingress resources](https://kubernetes.io/docs/concepts/services-networking/ingress/).

## Container dependencies

In the original ESGF Docker implementation, almost all the software was installed
from source, even software like Python and Java for which officially supported
and maintained containers exist in the Docker Hub Library. Whilst I appreciate
that this was done to maintain as much similarity with the ESGF Installer as
possible, I believe we should take this opportunity to stop rolling our own
source installations, as it can be error-prone.

Instead, this implementation takes the decision to use officially supported and
maintained base images where possible. This means that it now uses the following
images from the Docker Hub Library as the basis for `esgf-*` containers:

  * `solr:5.5`
  * `openjdk:8-{jre,jdk}`
  * `tomcat:8`
  * `python:2.7-slim`

In the original implementation, there was also an `esgf-node` image that served
as a base image for all other ESGF containers. As well as containing supervisor,
which was discussed above, this image also included a source build of Python 2.7
and a custom installation of the entire JDK, meaning that **every container**
had Python 2.7 and the entire JDK installed, even if it didn't need it!

This increases container bloat and also increases the attack surface of the
containers. It is also bad-practice to include the entire JDK on a production
server when the JRE is sufficient for running the application.

In this implementation, there is no common base image for every container. Instead,
the Tomcat and Django containers have their own inheritance hierarchy such that
Java tooling is not installed in the Django containers and vice-versa. See
[Container Architecture](../architecture) for details.
