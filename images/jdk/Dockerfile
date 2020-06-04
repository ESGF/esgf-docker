#####
## Image containing the full JDK
##
## Intended for use by builder images that need to unpack war files
## Runtime Java images should use the JRE only
#####

ARG ESGF_REPOSITORY_BASE=esgfdeploy
ARG ESGF_IMAGES_VERSION=latest
FROM ${ESGF_REPOSITORY_BASE}/base:${ESGF_IMAGES_VERSION}

USER root

RUN yum makecache && \
    yum install -y java-1.8.0-openjdk-devel-1.8.0.252.b09 && \
    yum clean all
