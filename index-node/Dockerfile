# ESGF index node:  esgf-search application running inside Tomcat

ARG ESGF_TOMCAT_VERSION=latest
FROM cedadev/esgf-tomcat:$ESGF_TOMCAT_VERSION

MAINTAINER Earth System Grid Federation <esgf-devel@lists.llnl.gov>

# Download and install esg-search war
ARG ESGF_DIST_URL=http://dist.ceda.ac.uk/esgf/dist
ENV ESGF_REPO $ESGF_DIST_URL
RUN curl -o $CATALINA_HOME/webapps/esg-search.war -sSL $ESGF_REPO/esg-search/esg-search.war

# Install environment customisations
COPY scripts/setenv.sh $CATALINA_HOME/bin/setenv.sh
