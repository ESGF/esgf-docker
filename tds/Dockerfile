#####
## Docker image for running the THREDDS Data Server (TDS) with Tomcat
#####

## In order to install the jars required, we need to unpack several war files.
##
## Unpacking a war requires the jar command, which is part of the JDK. However,
## we only want the JRE in the final container.
##
## To get around this, we use a separate build stage with the full JDK to
## download and unpack the wars, and copy the unpacked folder into the final container.

ARG ESGF_HUB=esgfhub
ARG ESGF_PREFIX=
ARG ESGF_VERSION=latest

# This build stage is required because COPY --from=$ARG is not supported
# https://github.com/moby/moby/issues/34482
FROM ${ESGF_HUB}/${ESGF_PREFIX}configure:${ESGF_VERSION} as configuration


#############
## Stage 1 ##
#############

FROM openjdk:8-jdk AS esgf-tds-unpack
ARG ESGF_ANSIBLE_VERSION=4.0.0-alpha1
ARG ESGF_REPO=https://github.com/ESGF/esgf-ansible/releases/download/$ESGF_ANSIBLE_VERSION

ARG NODE_MANAGER_VERSION=v1.0.5
ARG NODE_MANAGER_REPO=https://github.com/ESGF/esgf-node-manager/releases/download/$NODE_MANAGER_VERSION

ARG ESGF_SECURITY_VERSION=v2.8.9
ARG ESGF_SECURITY_REPO=https://github.com/ESGF/esgf-security/releases/download/$ESGF_SECURITY_VERSION

# First, download and unpack THREDDS
RUN mkdir /opt/thredds && \
    cd /opt/thredds && \
    TMPFILE=$(mktemp) && \
    curl -o $TMPFILE -fsSL $ESGF_REPO/thredds.war && \
    jar xvf $TMPFILE && \
    cd -

# Get jars required for TDS filters from the ESGF repo and install them
RUN cd /opt/thredds/WEB-INF/lib && \
    curl -O -fsSL $ESGF_REPO/xmlsec-1.4.7.jar && \
    curl -O -fsSL $ESGF_REPO/velocity-1.5.jar && \
    curl -Of -sSL $ESGF_REPO/serializer-2.9.1.jar && \
    curl -O -fsSL $ESGF_REPO/postgresql-8.4-703.jdbc3.jar && \
    curl -O -fsSL $ESGF_REPO/XSGroupRole-1.0.0.jar && \
    curl -O -fsSL $ESGF_REPO/commons-httpclient-3.1.jar && \
    curl -O -fsSL $ESGF_REPO/commons-lang-2.6.jar && \
    curl -O -fsSL $ESGF_REPO/jdom-legacy-1.1.3.jar && \
    curl -O -fsSL $ESGF_REPO/opensaml-2.6.6.jar && \
    curl -O -fsSL $ESGF_REPO/openws-1.5.6.jar && \
    curl -O -fsSL $ESGF_REPO/xmltooling-1.4.6.jar && \
    curl -O -fsSL $ESGF_REPO/esg-orp-2.10.11.jar && \
    curl -O -fsSL $NODE_MANAGER_REPO/esgf-node-manager-common-$NODE_MANAGER_VERSION.jar && \
    curl -O -fsSL $NODE_MANAGER_REPO/esgf-node-manager-filters-$NODE_MANAGER_VERSION.jar && \
    curl -O -fsSL $ESGF_SECURITY_REPO/esgf-security-$ESGF_SECURITY_VERSION.jar && \
    cd -

# FIXME: Obtain missing jars from ORP and old node-manager distributions
RUN TMPFILE=$(mktemp) && \
    curl -o $TMPFILE -fsSL $ESGF_REPO/esg-orp.war && \
    TMPDIR=$(mktemp -d) && \
    cd $TMPDIR && \
    jar xvf $TMPFILE && \
    rm -f $TMPFILE && \
    cp WEB-INF/lib/xalan-2.7.2.jar /opt/thredds/WEB-INF/lib/ && \
    cp WEB-INF/lib/xercesImpl-2.10.0.jar /opt/thredds/WEB-INF/lib/ && \
    cp WEB-INF/lib/xml-apis-1.4.01.jar /opt/thredds/WEB-INF/lib/ && \
    cp WEB-INF/lib/commons-io-2.4.jar /opt/thredds/WEB-INF/lib/ && \
    cd - && \
    rm -rf $TMPDIR
RUN TMPFILE=$(mktemp) && \
    curl -o $TMPFILE -fsSL $NODE_MANAGER_REPO/esgf-node-manager.war && \
    TMPDIR=$(mktemp -d) && \
    cd $TMPDIR && \
    jar xvf $TMPFILE && \
    rm -f $TMPFILE && \
    cp WEB-INF/lib/commons-dbcp-1.4.jar /opt/thredds/WEB-INF/lib/ && \
    cp WEB-INF/lib/commons-dbutils-1.3.jar /opt/thredds/WEB-INF/lib/ && \
    cp WEB-INF/lib/commons-pool-1.5.4.jar /opt/thredds/WEB-INF/lib/ && \
    cd - && \
    rm -rf $TMPDIR

# This is important to ensure the created files are writable by the root group later
RUN chmod -R g+w /opt/thredds


#############
## Stage 2 ##
#############

FROM ${ESGF_HUB}/${ESGF_PREFIX}tomcat:$ESGF_VERSION

MAINTAINER Earth System Grid Federation <esgf-devel@lists.llnl.gov>

ENV ESGF_HOME /esg

# We need rsync to do an intelligent copy of the THREDDS content skeleton (see below)
RUN apt-get update && apt-get install -y rsync && rm -rf /var/lib/apt/lists/*

# Copy the unpacked webapp from the previous build stage
COPY --from=esgf-tds-unpack --chown=1001:0 /opt/thredds $CATALINA_HOME/webapps/thredds

# Copy configuration and utils from esgf-configure
COPY --chown=1001:0 --from=configuration /esg /esg

# Install environment customisations, config files and templates
COPY scripts/setenv.sh $CATALINA_HOME/bin/
# Make sure this script runs after the settings are interpolated
COPY scripts/configure-thredds.sh /tomcat-init.d/
# TDS customized applicationContext.xml file with ESGF authorizer
COPY conf/applicationContext.xml $CATALINA_HOME/webapps/thredds/WEB-INF/
# TDS customized logging (uses DEBUG)
COPY conf/log4j2.xml $CATALINA_HOME/webapps/thredds/WEB-INF/classes/
# Template for web.xml - this is interpolated with environment vars at runtime
COPY conf/web.xml $CATALINA_HOME/webapps/thredds/WEB-INF/.defaults/web.xml
# Template for tomcat-users.xml - interpolated with environment vars at runtime
COPY conf/tomcat-users.xml $CATALINA_HOME/conf/.defaults/tomcat-users.xml

# Create the thredds content root owned by tomcat user and root group
RUN mkdir -p /esg/content/thredds/esgcet && \
    chown -R 1001:0 /esg/content/thredds && \
    chmod -R g+w /esg/content/thredds
# The threddsConfig.xml and root catalog.xml will normally not come from a volume
# as they don't change with publishing
# However, we might want to override them, so they should still come through the
# .defaults/.overrides mechanism
COPY conf/thredds /esg/content/thredds/.defaults

# Run as the tomcat user by default
USER 1001
