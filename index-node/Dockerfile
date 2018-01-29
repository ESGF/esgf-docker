# ESGF index node:  esgf-search application running inside Tomcat

ARG ESGF_TOMCAT_VERSION=latest
FROM cedadev/esgf-tomcat:$ESGF_TOMCAT_VERSION

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
COPY scripts/setenv.sh $CATALINA_HOME/bin/
COPY scripts/configure.sh /tomcat-init.d/
COPY templates/esgf.properties /esg/config/esgf.properties.template
COPY templates/esgf_shards_static.xml /esg/config/esgf_shards_static.xml.template
