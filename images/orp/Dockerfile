#####
## Docker image for the ESGF ORP tomcat application
#####

ARG ESGF_REPOSITORY_BASE=esgfhub
ARG ESGF_IMAGES_VERSION=latest

# Unpack the esg-orp war
ARG ESGF_ORP_ASSETS=https://github.com/ESGF/esg-orp/releases/download/
ARG ESGF_ORP_VERSION=v2.11.0
ARG WAR_LOCATION=$ESGF_ORP_ASSETS/$ESGF_ORP_VERSION/esg-orp.war
FROM ${ESGF_REPOSITORY_BASE}/tomcat-builder:${ESGF_IMAGES_VERSION} as builder

# Copy the unpacked contents into the runtime container
ARG WEBAPP_NAME=esg-orp
FROM ${ESGF_REPOSITORY_BASE}/tomcat-runtime:${ESGF_IMAGES_VERSION}

# Install custom startup scripts
ENV ESGF_HOSTCERT_DIR $ESGF_HOME/hostcert
COPY 01-keystore.sh $ESGF_INIT_DIR/
