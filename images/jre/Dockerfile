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
    yum install -y java-11-openjdk-headless-11.0.15.0.9 && \
    yum clean all

USER $ESGF_UID
