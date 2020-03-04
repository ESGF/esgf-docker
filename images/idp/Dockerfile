#####
## Docker image for the ESGF IDP tomcat application
#####

ARG ESGF_REPOSITORY_BASE=esgfhub
ARG ESGF_IMAGES_VERSION=latest

ARG WEBAPP_NAME=esgf-idp
ARG ESGF_IDP_ASSETS=https://github.com/ESGF/esgf-idp/releases/download/
ARG ESGF_IDP_VERSION=v2.8.8
ARG WAR_LOCATION=$ESGF_IDP_ASSETS/$ESGF_IDP_VERSION/$WEBAPP_NAME.war

FROM ${ESGF_REPOSITORY_BASE}/tomcat-builder:${ESGF_IMAGES_VERSION} as builder

FROM ${ESGF_REPOSITORY_BASE}/tomcat-runtime:${ESGF_IMAGES_VERSION}
