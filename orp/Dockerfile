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

ARG ESGF_TOMCAT_VERSION=latest

FROM openjdk:8-jdk AS esg-orp-unpack

# Download and unpack esg-orp war
ARG ESGF_REPO=http://dist.ceda.ac.uk/esgf/dist
RUN mkdir /opt/esg-orp && \
    cd /opt/esg-orp && \
    TMPFILE=$(mktemp) && \
    curl -o $TMPFILE -fsSL $ESGF_REPO/esg-orp/esg-orp.war && \
    jar xvf $TMPFILE


#############
## Stage 2 ##
#############

FROM cedadev/esgf-tomcat:$ESGF_TOMCAT_VERSION

MAINTAINER Earth System Grid Federation <esgf-devel@lists.llnl.gov>

# Copy the unpacked webapp from the previous build stage
COPY --from=esg-orp-unpack --chown=tomcat:tomcat /opt/esg-orp $CATALINA_HOME/webapps/esg-orp

# Remove all permissions from any user except tomcat on the orp webapp
RUN chmod -R o-rwx $CATALINA_HOME/webapps/esg-orp

# Copy configuration and utils from esgf-configure
COPY --from=cedadev/esgf-configure /esg/config /esg/config
# Make sure this script runs first by giving it a low ordinal
COPY --from=cedadev/esgf-configure /opt/esgf-docker/scripts/interpolate-configs.sh /tomcat-init.d/01-interpolate.sh
# Install esg-orp.properties template
COPY conf/esg-orp.properties.template $CATALINA_HOME/webapps/esg-orp/WEB-INF/classes/
# This script interpolates environment variables into esg-orp.properties at runtime before Tomcat runs
COPY scripts/configure-orp.sh /tomcat-init.d/02-configure-orp.sh
COPY scripts/setenv.sh $CATALINA_HOME/bin/setenv.sh
