# ESGF index node:  esgf-search application running inside Tomcat

ARG ESGF_HUB=cedadev
ARG ESGF_VERSION=latest

# This build stage is required because COPY --from=$ARG is not supported
# https://github.com/moby/moby/issues/34482
FROM ${ESGF_HUB}/esgf-configure:${ESGF_VERSION} as configuration

FROM ${ESGF_HUB}/esgf-tomcat:$ESGF_VERSION

MAINTAINER Earth System Grid Federation <esgf-devel@lists.llnl.gov>

# Install jq to allow us to easily parse responses from Solr during setup
RUN apt-get update && \
    apt-get install -y jq && \
    rm -rf /var/lib/apt/lists/*

# Download and install esg-search war
ARG ESGF_DIST_URL=http://dist.ceda.ac.uk/esgf/dist
ENV ESGF_REPO $ESGF_DIST_URL
RUN curl -o $CATALINA_HOME/webapps/esg-search.war -sSL $ESGF_REPO/esg-search/esg-search.war

# Install environment customisations
COPY --from=configuration /esg/config /esg/config
# Make sure the config interpolation runs first by giving it a low ordinal
COPY --from=configuration /opt/esgf-docker/scripts/interpolate-configs.sh /tomcat-init.d/01-interpolate.sh
COPY scripts/setenv.sh $CATALINA_HOME/bin/
# Make sure this runs after the config interpolation
COPY scripts/create-indices.sh /tomcat-init.d/02-create-indices.sh
