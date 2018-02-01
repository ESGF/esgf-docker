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

ARG ESGF_TOMCAT_VERSION=latest

FROM openjdk:8-jdk AS esgf-tds-unpack

ARG ESGF_REPO=http://dist.ceda.ac.uk/esgf

# First, download and unpack THREDDS
RUN mkdir /opt/thredds && \
    cd /opt/thredds && \
    TMPFILE=$(mktemp) && \
    curl -o $TMPFILE -fsSL $ESGF_REPO/dist/thredds/5.0/5.0.2/thredds.war && \
    jar xvf $TMPFILE && \
    cd -

# Get jars required for TDS filters from the ESGF repo and install them
RUN cd /opt/thredds/WEB-INF/lib && \
    curl -O -fsSL $ESGF_REPO/artifacts/repositories/esgf-repo-share/xml-security/xmlsec/1.4.2/xmlsec-1.4.2.jar && \
    curl -O -fsSL $ESGF_REPO/artifacts/repositories/esgf-repo-share/velocity/velocity/1.5/velocity-1.5.jar && \
    curl -Of -sSL $ESGF_REPO/artifacts/repositories/esgf-repo-share/xalan/serializer/2.9.1/serializer-2.9.1.jar && \
    curl -O -fsSL $ESGF_REPO/artifacts/repositories/esgf-repo-share/postgresql/postgresql/8.4-703.jdbc3/postgresql-8.4-703.jdbc3.jar && \
    curl -O -fsSL $ESGF_REPO/dist/filters/XSGroupRole-1.0.0.jar && \
    curl -O -fsSL $ESGF_REPO/dist/filters/commons-httpclient-3.1.jar && \
    curl -O -fsSL $ESGF_REPO/dist/filters/commons-lang-2.6.jar && \
    curl -O -fsSL $ESGF_REPO/dist/filters/jdom-legacy-1.1.3.jar && \
    curl -O -fsSL $ESGF_REPO/dist/filters/opensaml-2.3.2.jar && \
    curl -O -fsSL $ESGF_REPO/dist/filters/openws-1.3.1.jar && \
    curl -O -fsSL $ESGF_REPO/dist/filters/xmltooling-1.2.2.jar && \
    curl -O -fsSL $ESGF_REPO/dist/esg-orp/esg-orp-2.9.6.jar && \
    curl -O -fsSL $ESGF_REPO/dist/esgf-node-manager/esgf-node-manager-common-1.0.0.jar && \
    curl -O -fsSL $ESGF_REPO/dist/esgf-node-manager/esgf-node-manager-filters-1.0.0.jar && \
    curl -O -fsSL $ESGF_REPO/dist/esgf-security/esgf-security-2.7.10.jar && \
    cd -

# FIXME: Obtain missing jars from ORP and old node-manager distributions
RUN TMPFILE=$(mktemp) && \
    curl -o $TMPFILE -fsSL $ESGF_REPO/dist/esg-orp/esg-orp.war && \
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
    curl -o $TMPFILE -fsSL $ESGF_REPO/dist/esgf-node-manager/esgf-node-manager.war && \
    TMPDIR=$(mktemp -d) && \
    cd $TMPDIR && \
    jar xvf $TMPFILE && \
    rm -f $TMPFILE && \
    cp WEB-INF/lib/commons-dbcp-1.4.jar /opt/thredds/WEB-INF/lib/ && \
    cp WEB-INF/lib/commons-dbutils-1.3.jar /opt/thredds/WEB-INF/lib/ && \
    cp WEB-INF/lib/commons-pool-1.5.4.jar /opt/thredds/WEB-INF/lib/ && \
    cd - && \
    rm -rf $TMPDIR


#############
## Stage 2 ##
#############

FROM cedadev/esgf-tomcat:$ESGF_TOMCAT_VERSION

MAINTAINER Earth System Grid Federation <esgf-devel@lists.llnl.gov>

ENV ESGF_HOME /esg

# We need rsync to do an intelligent copy of the THREDDS content skeleton (see below)
RUN apt-get update && apt-get install -y rsync && rm -rf /var/lib/apt/lists/*

# Copy the unpacked webapp from the previous build stage
COPY --from=esgf-tds-unpack --chown=tomcat:tomcat /opt/thredds $CATALINA_HOME/webapps/thredds

# Remove all permissions from any user except tomcat on the webapp
RUN chmod -R o-rwx $CATALINA_HOME/webapps/thredds

# Copy configuration and utils from esgf-configure
COPY --from=cedadev/esgf-configure /esg/config /esg/config
# Make sure this script runs first by giving it a low ordinal
COPY --from=cedadev/esgf-configure /opt/esgf-docker/scripts/interpolate-configs.sh /tomcat-init.d/01-interpolate.sh

# Install environment customisations, config files and templates
COPY scripts/setenv.sh $CATALINA_HOME/bin/
# Make sure this script runs after the settings are interpolated
COPY scripts/setup-thredds.sh /tomcat-init.d/02-setup-thredds.sh
# TDS customized applicationContext.xml file with ESGF authorizer
COPY conf/applicationContext.xml $CATALINA_HOME/webapps/thredds/WEB-INF/
# TDS customized logging (uses DEBUG)
COPY conf/log4j2.xml $CATALINA_HOME/webapps/thredds/WEB-INF/classes/
# Template for web.xml - this is interpolated with environment vars at runtime by setup-thredds.sh
COPY conf/web.xml.template $CATALINA_HOME/webapps/thredds/WEB-INF/

# Set up a skeleton for the THREDDS content root
#
# We need to do this because, in order to be persistent, the THREDDS content
# directory should be mounted in. However, we cannot rely on the Docker volumes
# behaviour of copying existing content to an empty volume, as this does not
# happen with volumes in Kubernetes.
RUN mkdir -p /esg/content/thredds-skel/esgcet
COPY conf/threddsConfig.xml /esg/content/thredds-skel/
COPY conf/catalog.xml /esg/content/thredds-skel/
COPY conf/catalog.xml /esg/content/thredds-skel/
COPY conf/esgcet/catalog.xml /esg/content/thredds-skel/esgcet/
