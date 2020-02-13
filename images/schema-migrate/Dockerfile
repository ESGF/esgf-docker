#####
## Docker image for running schema migrations
##
## Can be used as an init container for Kubernetes deployments
#####

ARG ESGF_REPOSITORY_BASE=esgfhub
ARG ESGF_IMAGES_VERSION=latest
FROM ${ESGF_REPOSITORY_BASE}/conda-builder:${ESGF_IMAGES_VERSION} as builder

USER root

RUN yum makecache && \
    yum install -y gcc postgresql postgresql-devel && \
    yum clean all

# Install the schema migration package for the security database
ARG ESGF_SECURITY_ASSETS=https://github.com/ESGF/esgf-security/releases/download/
ARG ESGF_SECURITY_VERSION=v2.8.11
ARG ESGF_SECURITY_DB_VERSION=0.1.7
ARG ESGF_SECURITY_DB_EGG=$ESGF_SECURITY_ASSETS/$ESGF_SECURITY_VERSION/esgf_security-$ESGF_SECURITY_DB_VERSION-py2.7.egg
RUN conda install "python<3" && \
    conda clean --all -f -y && \
    easy_install "$ESGF_SECURITY_DB_EGG"


FROM ${ESGF_REPOSITORY_BASE}/conda-runtime:${ESGF_IMAGES_VERSION}
