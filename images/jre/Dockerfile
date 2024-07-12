#####
## Image containing the JRE
##
## Intended for use as a base image for runtime Java images
#####

ARG ESGF_REPOSITORY_BASE=esgfdeploy
ARG ESGF_IMAGES_VERSION=latest
FROM ${ESGF_REPOSITORY_BASE}/base:${ESGF_IMAGES_VERSION}

USER root

RUN dnf makecache && \
    dnf install -y java-11-openjdk-headless-11.0.23.0.9-3.el9 && \
    dnf clean all

USER $ESGF_UID
