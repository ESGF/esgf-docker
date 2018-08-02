#####
## Docker image for running the ESGF Search application with Tomcat
#####

## In order to modify application-context.xml before Tomcat runs, we need to
## unpack the war manually.
##
## Unpacking a war requires the jar command, which is part of the JDK. However,
## we only want the JRE in the final container.
##
## To get around this, we use a separate build stage with the full JDK to
## download and unpack the war, and copy the unpacked folder into the final container.

ARG ESGF_HUB=esgfhub
ARG ESGF_PREFIX=
ARG ESGF_VERSION=latest
ARG ESGF_HUB_ALT=esgfhublc

# This build stage is required because COPY --from=$ARG is not supported
# https://github.com/moby/moby/issues/34482
FROM ${ESGF_HUB}/${ESGF_PREFIX}configure:${ESGF_VERSION} as configuration

#############
## Stage 1 ##
#############

FROM openjdk:8-jdk AS esg-search-unpack

# Download and unpack war
ARG ESGF_REPO=http://dist.ceda.ac.uk/esgf/dist
RUN mkdir /opt/esg-search && \
    cd /opt/esg-search && \
    TMPFILE=$(mktemp) && \
    curl -o $TMPFILE -fsSL $ESGF_REPO/esg-search/esg-search.war && \
    jar xvf $TMPFILE && \
    chmod -R g+w /opt/esg-search


#############
## Stage 2 ##
#############

FROM ${ESGF_HUB_ALT}/${ESGF_PREFIX}tomcat:$ESGF_VERSION

MAINTAINER Earth System Grid Federation <esgf-devel@lists.llnl.gov>

# Copy the unpacked webapp from the previous build stage
# Ensure it is owned by the tomcat user and root group, as we want any user in
# the root group to be able to run the container
COPY --from=esg-search-unpack --chown=1001:0 /opt/esg-search $CATALINA_HOME/webapps/esg-search

# Make sure esgf_shards.xml is recognised as a shards file as well as esgf_shards_static.xml
RUN sed -i \
      "s/\/esg\/config\/esgf_shards_static\.xml/\/esg\/config\/esgf_shards\.xml, \0/g" \
      $CATALINA_HOME/webapps/esg-search/WEB-INF/classes/esg/search/config/application-context.xml

# Install environment customisations
# Make sure this runs before the config interpolation
COPY scripts/check-variables.sh /tomcat-init.d/01-check-variables.sh
# Ensure the config directory is owned by the tomcat user and root group
RUN mkdir -p /esg/config && chown 1001:0 /esg/config && chmod 775 /esg/config
COPY --chown=1001:0 --from=configuration /esg/config /esg/config
# Make sure the config interpolation runs first by giving it a low ordinal
COPY --from=configuration /opt/esgf-docker/scripts/interpolate-configs.sh /tomcat-init.d/02-interpolate.sh
COPY scripts/setenv.sh $CATALINA_HOME/bin/

# Run as the tomcat user by default
USER 1001
