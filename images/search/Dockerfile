#####
## Docker image for the ESGF search tomcat application
#####

ARG ESGF_REPOSITORY_BASE=esgfhub
ARG ESGF_IMAGES_VERSION=latest

# Unpack the war
ARG WEBAPP_NAME=esg-search
ARG ESGF_SEARCH_ASSETS=https://github.com/ESGF/esg-search/releases/download/
ARG ESGF_SEARCH_VERSION=v4.17.10
ARG WAR_LOCATION=$ESGF_SEARCH_ASSETS/$ESGF_SEARCH_VERSION/$WEBAPP_NAME.war
FROM ${ESGF_REPOSITORY_BASE}/tomcat-builder:${ESGF_IMAGES_VERSION} as builder

# Copy the unpacked contents into the runtime container
FROM ${ESGF_REPOSITORY_BASE}/tomcat-runtime:${ESGF_IMAGES_VERSION}
