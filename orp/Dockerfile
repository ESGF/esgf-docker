#####
## Docker image for running the ESGF Openid Relying Party (ORP) with Tomcat
#####

## In order to put the esg-orp.properties file where it needs to be, we need to
## unpack esg-orp.war prior to Tomcat starting for the first time.
##
## Unpacking a war requires the jar command, which is part of the JDK. However,
## we only want the JRE in the final container.
##
## To get around this, we use a separate build stage with the full JDK to
## download and unpack the war, and copy the unpacked folder into the final container.

ARG ESGF_HUB=esgfhub
ARG ESGF_PREFIX=
ARG ESGF_VERSION=latest

# This build stage is required because COPY --from=$ARG is not supported
# https://github.com/moby/moby/issues/34482
FROM ${ESGF_HUB}/${ESGF_PREFIX}configure:${ESGF_VERSION} as configuration

FROM openjdk:8-jdk AS esg-orp-unpack

# Download and unpack esg-orp war
ARG ESGF_REPO=http://dist.ceda.ac.uk/esgf/dist
RUN mkdir /opt/esg-orp && \
    cd /opt/esg-orp && \
    TMPFILE=$(mktemp) && \
    curl -o $TMPFILE -fsSL $ESGF_REPO/esg-orp/esg-orp.war && \
    jar xvf $TMPFILE && \
    chmod -R g+w /opt/esg-orp


#############
## Stage 2 ##
#############

FROM ${ESGF_HUB}/${ESGF_PREFIX}tomcat:$ESGF_VERSION

MAINTAINER Earth System Grid Federation <esgf-devel@lists.llnl.gov>

# Copy the unpacked webapp from the previous build stage
# Ensure it is owned by the tomcat user and root group, as we want any user in
# the root group to be able to run the container
COPY --from=esg-orp-unpack --chown=1001:0 /opt/esg-orp $CATALINA_HOME/webapps/esg-orp

# Copy configuration and utils from esgf-configure
# Ensure the config directory is owned by the tomcat user and root group
RUN mkdir -p /esg/config && chown 1001:0 /esg/config && chmod 775 /esg/config
COPY --chown=1001:0 --from=configuration /esg/config /esg/config
# Make sure this script runs first by giving it a low ordinal
COPY --from=configuration /opt/esgf-docker/scripts/interpolate-configs.sh /tomcat-init.d/01-interpolate.sh
# Install esg-orp.properties template
COPY conf/esg-orp.properties.template $CATALINA_HOME/webapps/esg-orp/WEB-INF/classes/
# This script interpolates environment variables into esg-orp.properties at runtime before Tomcat runs
COPY scripts/configure-orp.sh /tomcat-init.d/02-configure-orp.sh
COPY scripts/setenv.sh $CATALINA_HOME/bin/setenv.sh

# Run as the tomcat user by default
USER 1001
