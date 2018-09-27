#####
## Docker image for running the ESGF Identity Provider (IDP) with Tomcat
#####

## In order to put the yadis-config.xml file where it needs to be before Tomcat
## runs, we need to unpack the war manually.
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

FROM openjdk:8-jdk AS esgf-idp-unpack

# Download and unpack esg-orp war
ARG ESGF_REPO=http://dist.ceda.ac.uk/esgf/dist
RUN mkdir /opt/esgf-idp && \
    cd /opt/esgf-idp && \
    TMPFILE=$(mktemp) && \
    curl -o $TMPFILE -fsSL $ESGF_REPO/esgf-idp/esgf-idp.war && \
    jar xvf $TMPFILE && \
    chmod -R g+w /opt/esgf-idp


#############
## Stage 2 ##
#############

FROM ${ESGF_HUB}/${ESGF_PREFIX}tomcat:$ESGF_VERSION

MAINTAINER Earth System Grid Federation <esgf-devel@lists.llnl.gov>

ENV ESGF_HOME /esg

# Copy the unpacked webapp from the previous build stage
# Ensure it is owned by the tomcat user and root group, as we want any user in
# the root group to be able to run the container
COPY --from=esgf-idp-unpack --chown=1001:0 /opt/esgf-idp $CATALINA_HOME/webapps/esgf-idp

# Copy configuration and utils from esgf-configure
COPY --chown=1001:0 --from=configuration /esg /esg
# Install initialisation script
COPY ./scripts/configure.sh /tomcat-init.d/
# Install environment customisations
COPY ./scripts/setenv.sh $CATALINA_HOME/bin/
# Override Yadis configuration file to use full SLCS URL
COPY ./conf/yadis-config.xml $CATALINA_HOME/webapps/esgf-idp/WEB-INF/classes/esg/idp/config/yadis-config.xml

# Run as the tomcat user by default
USER 1001
