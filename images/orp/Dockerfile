#####
## Docker image for the ESGF ORP tomcat application
#####

ARG ESGF_REPOSITORY_BASE=esgfhub
ARG ESGF_IMAGES_VERSION=latest

# Unpack the esg-orp war
ARG WEBAPP_NAME=esg-orp
ARG ESGF_ORP_ASSETS=https://github.com/ESGF/esg-orp/releases/download/
ARG ESGF_ORP_VERSION=v2.11.0
ARG WAR_LOCATION=$ESGF_ORP_ASSETS/$ESGF_ORP_VERSION/$WEBAPP_NAME.war
FROM ${ESGF_REPOSITORY_BASE}/tomcat-builder:${ESGF_IMAGES_VERSION} as builder

# Copy the unpacked contents into the runtime container
FROM ${ESGF_REPOSITORY_BASE}/tomcat-runtime:${ESGF_IMAGES_VERSION}

# Install custom config and startup scripts
ENV ESGF_HOSTCERT_DIR $ESGF_HOME/hostcert
COPY 01-keystore.sh $ESGF_INIT_DIR/
COPY esg-orp.properties $CATALINA_HOME/webapps/esg-orp/WEB-INF/classes/
