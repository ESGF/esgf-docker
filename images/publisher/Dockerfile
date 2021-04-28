#####
## Docker image for an ESGF publisher client application
#####

ARG ESGF_REPOSITORY_BASE=esgfdeploy
ARG ESGF_IMAGES_VERSION=latest
ARG GIT_REPOSITORY=https://github.com/ESGF/esg-publisher.git
ARG GIT_VERSION=no-auth

FROM ${ESGF_REPOSITORY_BASE}/python-build:${ESGF_IMAGES_VERSION} as python-build

FROM ${ESGF_REPOSITORY_BASE}/base:${ESGF_IMAGES_VERSION}
