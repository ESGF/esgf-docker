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

ARG ESGF_HUB=cedadev
ARG ESGF_VERSION=latest

# This build stage is required because COPY --from=$ARG is not supported
# https://github.com/moby/moby/issues/34482
FROM ${ESGF_HUB}/esgf-configure:${ESGF_VERSION} as configuration

FROM openjdk:8-jdk AS esgf-idp-unpack

# Download and unpack esg-orp war
ARG ESGF_REPO=http://dist.ceda.ac.uk/esgf/dist
RUN mkdir /opt/esgf-idp && \
    cd /opt/esgf-idp && \
    TMPFILE=$(mktemp) && \
    curl -o $TMPFILE -fsSL $ESGF_REPO/esgf-idp/esgf-idp.war && \
    jar xvf $TMPFILE


#############
## Stage 2 ##
#############

FROM ${ESGF_HUB}/esgf-tomcat:$ESGF_VERSION

MAINTAINER Earth System Grid Federation <esgf-devel@lists.llnl.gov>

ENV ESGF_HOME /esg

# Copy the unpacked webapp from the previous build stage
COPY --from=esgf-idp-unpack --chown=tomcat:tomcat /opt/esgf-idp $CATALINA_HOME/webapps/esgf-idp
# Remove all permissions from any user except tomcat on the webapp
RUN chmod -R o-rwx $CATALINA_HOME/webapps/esgf-idp

# Copy configuration and utils from esgf-configure
COPY --from=configuration /esg/config /esg/config
COPY --from=configuration /opt/esgf-docker/scripts/interpolate-configs.sh /tomcat-init.d/

# Install environment customisations, config files and templates
COPY scripts/setenv.sh $CATALINA_HOME/bin/
# Override Yadis configuration file to use full SLCS URL
COPY conf/yadis-config.xml $CATALINA_HOME/webapps/esgf-idp/WEB-INF/classes/esg/idp/config/yadis-config.xml
