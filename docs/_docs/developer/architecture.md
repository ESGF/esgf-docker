---
title: Container Architecture
category: Developers
order: 2.1
toc: false
---

The following text-diagram shows the inheritance hierarchy of the ESGF Docker containers:

```
centos/postgresql-96-centos7 -> esgfhub/postgres -> esgfhub/postgres-security

nginx -> esgfhub/proxy

solr:6.6 -> esgfhub/solr

alpine -> esgfhub/configure

python:2.7-slim -> esgfhub/django -> esgfhub/auth
                                  -> esgfhub/cog
                                  -> esgfhub/slcs

openjdk:8-jre -> tomcat:8 -> esgfhub/tomcat -> esgfhub/idp-node
                                            -> esgfhub/index-node
                                            -> esgfhub/orp
                                            -> esgfhub/tds

continuumio/miniconda -> esgfhub/publisher
```

## Configuration

A big effort has been made to make each container capable of being configured
using environment variables and minimal mounts (e.g. secrets and certificates).
Each container image includes a copy of all the configuration files it requires
to start. Some of these configuration files are "static", i.e. they do not depend
on environment variables, and others are "templates", where values from environment
variables are substituted in at runtime. If an environment variable is required but
not given, the container will fail to start.

Templating of configuration files is done using [gomplate](https://gomplate.hairyhenderson.ca/),
a lightweight tool that enables the use of the [Go template language](https://golang.org/pkg/text/template/)
with some useful extensions. This tool was chosen because it is lightweight, yet enables a
more expressive template language than something like `envsubst`, including loops and conditionals.

Individual files or templates in a configuration directory can be replaced by mounting
a directory of override files. For example, to specify other members in a federation
by overriding files in `/esg/config`, a directory containing override files would be
mounted at `/esg/config/.overrides`. The containers know to merge these files with the
existing defaults.

However, the containers are all capable of configuring themselves in a "standalone"
configuration, i.e. without any other federation members, using only environment
variables.

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
that are not required in the final image - for example, the build image for
[esgfhub/slcs](https://github.com/ESGF/esgf-docker/blob/master/slcs/Dockerfile)
installs `build-essential` (for GCC) and the header files for OpenSSL, neither
of which are required to actually run the application. The resulting
[Python wheels](https://pythonwheels.com/) are copied into the application image,
where they are installed.

### "Mixin" images

Mixin images are images that are never intended to be run, and exist purely
as a way to share files with other images using the `COPY --from=<image>` syntax.
This is mainly to work-around the fact that Docker does not allow symlinks in a
build context.

In particular, the `esgfhub/configure` image is a mixin image that exists
purely to allow other images to `COPY` the default templates for `/esg/config`
and some useful scripts.
