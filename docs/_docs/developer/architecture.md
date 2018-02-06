---
title: Container Architecture
category: Developers
order: 3
---

The following text-diagram shows the inheritance hierarchy of the ESGF Docker containers:

```
centos:6 -> esgf-postgres

nginx -> esgf-proxy

solr:5.5 -> esgf-solr

alpine -> esgf-configure

python:2.7-slim -> esgf-django -> esgf-auth
                               -> esgf-cog
                               -> esgf-slcs

openjdk:8-jre -> tomcat:8 -> esgf-tomcat -> esgf-idp-node
                                         -> esgf-index-node
                                         -> esgf-orp
                                         -> esgf-tds
```

## Configuration

A big effort has been made to make each container capable of configuring itself
using environment variables. Each container image includes a copy of all the
configuration files it requires to start. Some of these configuration files are
"static", i.e. they do not depend on environment variables, and others are
"templates", where values from environment variables are substituted in at runtime.
If an environment variable is required but not given, the container will fail to start.

Individual configuration files or templates can be replaced by mounting in an
alternative, for example to specify other members in a federation. However, the
containers are all capable of configuring themselves in a "standalone"
configuration, i.e. without any other federation members, without mounting anything.

## Build and "mixin" images

Build and "mixin" images both make use of the same capability in different
ways - namely the ability of the
[COPY statement](https://docs.docker.com/engine/reference/builder/#copy) in a
Dockerfile to accept a `--from` argument. The `--from` argument allows for the
copying of files from another container image or build stage without inheriting
from that image.

### Build images

Build images make use of the fact that Dockerfiles allow multiple `FROM`
statements to be used in the process of building an image. Each `FROM` statement
represents a new stage in the building of the final image. Images can pull in
files from previous stages using the `COPY --from=<build-stage>` syntax. This
allows us to install the minimum amount of software required to run an application
in the final image, reducing container bloat and potential attack surface.

A build image can include dependencies that are only required when building
that are not required in the final image - for example, the build image for the
[esgf-slcs](https://github.com/cedadev/esgf-docker/blob/master/slcs/Dockerfile)
installs `build-essential` (for GCC) and the header files for OpenSSL, neither
of which are required to actually run the application. The resulting
[Python wheels](https://pythonwheels.com/) are copied into the application image,
where they are installed.

### "Mixin" images

Mixin images are images that are never intended to be run, and exist purely
as a way to share files with other images using the `COPY --from=<image>` syntax.
This is mainly to work-around the fact that Docker does not allow symlinks in a
build context.

In particular, the `esgf-configure` container is a mixin container, that exists
purely to allow other images to `COPY` the default templates for `/esg/config`
and some useful scripts.
