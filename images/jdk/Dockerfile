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

RUN dnf makecache && \
    dnf install -y java-11-openjdk-devel-11.0.23.0.9-3.el9 && \
    dnf clean all
