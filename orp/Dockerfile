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


#############
## Stage 1 ##
#############

FROM openjdk:8-jdk AS esg-orp-unpack

# Download and unpack esg-orp war
ARG ORP_VERSION=v2.10.10
ARG ORP_REPO=https://github.com/ESGF/esg-orp/releases/download/$ORP_VERSION

RUN mkdir /opt/esg-orp && \
    cd /opt/esg-orp && \
    TMPFILE=$(mktemp) && \
    curl -o $TMPFILE -fsSL $ORP_REPO/esg-orp.war && \
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
COPY --chown=1001:0 --from=configuration /esg /esg
# Install customised esg-orp.properties template
COPY ./conf $CATALINA_HOME/webapps/esg-orp/WEB-INF/classes/.defaults
# Install initialisation script
COPY ./scripts/configure.sh /tomcat-init.d/
# Install environment customisations
COPY ./scripts/setenv.sh $CATALINA_HOME/bin/

# Run as the tomcat user by default
USER 1001
