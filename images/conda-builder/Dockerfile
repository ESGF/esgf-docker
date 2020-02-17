#####
## Base image for building Python wheels using conda
##
## It is designed to provide wheels to wheels to a runtime image, which avoids
## having build dependencies, e.g. compilers, git, in the final image
#####

ARG ESGF_REPOSITORY_BASE=esgfhub
ARG ESGF_IMAGES_VERSION=latest
FROM ${ESGF_REPOSITORY_BASE}/conda:${ESGF_IMAGES_VERSION}

USER root

# Install common dependencies, e.g. git
RUN yum makecache && yum install -y git && yum clean all

USER $ESG_UID
