#####
## Image containing the JRE
##
## Intended for use as a base image for runtime Java images
#####

ARG ESGF_REPOSITORY_BASE=esgfdeploy
ARG ESGF_IMAGES_VERSION=latest
FROM ${ESGF_REPOSITORY_BASE}/base:${ESGF_IMAGES_VERSION}

USER root

RUN yum makecache && \
    yum install -y java-1.8.0-openjdk-headless-1.8.0.292.b10 && \
    yum clean all

USER $ESGF_UID
