# Docker image containing the THREDDS Data Server (TDS) 
# customized with ESGF access control filters

ARG ESGF_IMAGES_HUB=esgfhub
ARG ESGF_VERSION=devel

FROM $ESGF_IMAGES_HUB/esgf-tomcat:$ESGF_VERSION

MAINTAINER ESGF <esgf-devel@lists.llnl.gov>

# default ESGF repository
ARG ESGF_REPO=http://distrib-coffee.ipsl.jussieu.fr/pub/esgf

#============================================

# update system libraries
RUN yum -y update; yum clean all

# install TDS
RUN mkdir -p /usr/local/tomcat/webapps/thredds
#COPY thredds/thredds.war /usr/local/tomcat/webapps/thredds/thredds.war
ADD $ESGF_REPO/dist/thredds/5.0/5.0.2/thredds.war /usr/local/tomcat/webapps/thredds/
RUN cd /usr/local/tomcat/webapps/thredds && \
    jar xvf thredds.war && \
    rm thredds.war && \
    chown -R tomcat:tomcat /usr/local/tomcat/webapps/thredds

# TDS configuration root
RUN mkdir -p /esg/content/thredds

# TDS memory configuration
COPY conf/threddsConfig.xml  /esg/content/thredds/threddsConfig.xml

# ESGF root catalog
COPY conf/catalog.xml /esg/content/thredds/catalog.xml-esgcet
#COPY thredds/conf/esgcet/catalog.xml /esg/content/thredds/esgcet/catalog.xml
RUN mkdir -p /esg/content/thredds/esgcet

# TDS customized applicationContext.xml file with ESGF authorizer
COPY conf/applicationContext.xml /usr/local/tomcat/webapps/thredds/WEB-INF/applicationContext.xml

# TDS jars necessary to support ESGF security filters
# some jars are retrieved from the ESGF repository
# other jars are copied from the unpacked ORP or NM distributions
#COPY  thredds/jars/*  $CATALINA_HOME/webapps/thredds/WEB-INF/lib/

ADD $ESGF_REPO/dist/filters/XSGroupRole-1.0.0.jar $CATALINA_HOME/webapps/thredds/WEB-INF/lib/XSGroupRole-1.0.0.jar
ADD $ESGF_REPO/dist/filters/commons-httpclient-3.1.jar $CATALINA_HOME/webapps/thredds/WEB-INF/lib/commons-httpclient-3.1.jar
ADD $ESGF_REPO/dist/filters/commons-lang-2.6.jar $CATALINA_HOME/webapps/thredds/WEB-INF/lib/commons-lang-2.6.jar
# FIXME
COPY etc/esg-orp-2.9.6.jar $CATALINA_HOME/webapps/thredds/WEB-INF/lib/esg-orp-2.9.6.jar
#ADD $ESGF_REPO/dist/esg-orp/esg-orp-2.9.6.jar $CATALINA_HOME/webapps/thredds/WEB-INF/lib/esg-orp-2.9.6.jar
ADD $ESGF_REPO/dist/esgf-node-manager/esgf-node-manager-common-1.0.0.jar $CATALINA_HOME/webapps/thredds/WEB-INF/lib/esgf-node-manager-common-1.0.0.jar
ADD $ESGF_REPO/dist/esgf-node-manager/esgf-node-manager-filters-1.0.0.jar $CATALINA_HOME/webapps/thredds/WEB-INF/lib/esgf-node-manager-filters-1.0.0.jar
ADD $ESGF_REPO/dist/esgf-security/esgf-security-2.7.10.jar $CATALINA_HOME/webapps/thredds/WEB-INF/lib/esgf-security-2.7.15.jar
ADD $ESGF_REPO/dist/filters/jdom-legacy-1.1.3.jar $CATALINA_HOME/webapps/thredds/WEB-INF/lib/jdom-legacy-1.1.3.jar
ADD $ESGF_REPO/dist/filters/opensaml-2.3.2.jar $CATALINA_HOME/webapps/thredds/WEB-INF/lib/opensaml-2.3.2.jar
ADD $ESGF_REPO/dist/filters/openws-1.3.1.jar $CATALINA_HOME/webapps/thredds/WEB-INF/lib/openws-1.3.1.jar
ADD $ESGF_REPO/dist/filters/xmltooling-1.2.2.jar $CATALINA_HOME/webapps/thredds/WEB-INF/lib/xmltooling-1.2.2.jar

ADD $ESGF_REPO/artifacts/repositories/esgf-repo-share/xml-security/xmlsec/1.4.2/xmlsec-1.4.2.jar $CATALINA_HOME/webapps/thredds/WEB-INF/lib/xmlsec-1.4.2.jar
ADD $ESGF_REPO/artifacts/repositories/esgf-repo-share/velocity/velocity/1.5/velocity-1.5.jar $CATALINA_HOME/webapps/thredds/WEB-INF/lib/velocity-1.5.jar
ADD $ESGF_REPO/artifacts/repositories/esgf-repo-share/xalan/serializer/2.9.1/serializer-2.9.1.jar $CATALINA_HOME/webapps/thredds/WEB-INF/lib/serializer-2.9.1.jar
ADD $ESGF_REPO/artifacts/repositories/esgf-repo-share/postgresql/postgresql/8.4-703.jdbc3/postgresql-8.4-703.jdbc3.jar $CATALINA_HOME/webapps/thredds/WEB-INF/lib/postgresql-8.4-703.jdbc3.jar

# FIXME: must obtain missing jars from ORP and old NODE-MANAGER distributions
ADD $ESGF_REPO/dist/esg-orp/esg-orp.war /tmp/esg-orp/esg-orp.war
RUN cd /tmp/esg-orp && \
    jar xvf esg-orp.war && \
    cp WEB-INF/lib/xalan-2.7.2.jar $CATALINA_HOME/webapps/thredds/WEB-INF/lib/xalan-2.7.2.jar && \
    cp WEB-INF/lib/xercesImpl-2.10.0.jar $CATALINA_HOME/webapps/thredds/WEB-INF/lib/xercesImpl-2.10.0.jar && \
    cp WEB-INF/lib/xml-apis-1.4.01.jar $CATALINA_HOME/webapps/thredds/WEB-INF/lib/xml-apis-1.4.01.jar && \
    cp WEB-INF/lib/commons-io-2.4.jar $CATALINA_HOME/webapps/thredds/WEB-INF/lib/commons-io-2.4.jar
RUN rm -rf /tmp/esgf-orp

ADD $ESGF_REPO/dist/esgf-node-manager/esgf-node-manager.war /tmp/esgf-node-manager/esgf-node-manager.war
RUN cd /tmp/esgf-node-manager && \
    jar xvf esgf-node-manager.war && \
    cp WEB-INF/lib/commons-dbcp-1.4.jar $CATALINA_HOME/webapps/thredds/WEB-INF/lib/commons-dbcp-1.4.jar && \
    cp WEB-INF/lib/commons-dbutils-1.3.jar $CATALINA_HOME/webapps/thredds/WEB-INF/lib/commons-dbutils-1.3.jar && \
    cp WEB-INF/lib/commons-pool-1.5.4.jar $CATALINA_HOME/webapps/thredds/WEB-INF/lib/commons-pool-1.5.4.jar
RUN rm -rf /tmp/esgf-node-manager

# TDS customized logging (uses DEBUG)
COPY conf/log4j2.xml /usr/local/tomcat/webapps/thredds/WEB-INF/classes/log4j2.xml

# data node scripts
COPY scripts/ /usr/local/bin/

# TDS test ESGF catalogs
# COPY esgf-content/thredds/ /esg/content/thredds/

# TDS catalogs location
#RUN mkdir -p /esg/content/thredds/esgcet

# change ownership of content directory
RUN chown -R tomcat:tomcat  /esg/content/thredds/
# change ownership of source directory
RUN chown -R tomcat:tomcat $CATALINA_HOME/webapps/thredds

ENTRYPOINT /usr/local/bin/docker-entrypoint.sh
