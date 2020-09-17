#####
## Docker image that can be used to build wheels for a Python application and its dependencies
#####

ARG ESGF_REPOSITORY_BASE=esgfdeploy
ARG ESGF_IMAGES_VERSION=latest
FROM ${ESGF_REPOSITORY_BASE}/conda:${ESGF_IMAGES_VERSION}

USER root

# Install common dependencies:
#   gcc as it is often required to build things
#   git for projects that use setuptools_scm
RUN yum makecache && yum install -y gcc git && yum clean all

# Use ONBUILD triggers to checkout the application code
#   Clone the repository and checkout the version
ONBUILD ARG GIT_REPOSITORY
ONBUILD ARG GIT_VERSION
#   Make sure that any git submodules are also pulled
ONBUILD RUN \
    git clone $GIT_REPOSITORY /application && \
    pushd /application && \
    git checkout $GIT_VERSION && \
    git submodule update --init --recursive && \
    popd

# Use ONBUILD triggers to build the wheels
#   Move into the application source directory so that consumers can use relative requirements paths
ONBUILD WORKDIR /application
#   Allow the requirements file to be overridden, using /application/requirements.txt by default
ONBUILD ARG REQUIREMENTS_FILE=./requirements.txt
#   Build wheels for the application
ONBUILD RUN \
    pip wheel \
      --wheel-dir /build/wheelhouse \
      --no-deps \
      --requirement $REQUIREMENTS_FILE && \
    pip wheel \
      --wheel-dir /build/wheelhouse \
      --no-deps \
      /application

ONBUILD USER $ESGF_UID
