#####
## Image containing rsync for use when synchronising catalogs
#####

ARG ESGF_REPOSITORY_BASE=esgfdeploy
ARG ESGF_IMAGES_VERSION=latest
FROM ${ESGF_REPOSITORY_BASE}/base:${ESGF_IMAGES_VERSION}

USER root

RUN yum makecache && yum install -y rsync && yum clean all

USER $ESGF_UID
