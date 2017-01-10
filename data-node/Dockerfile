# ESGF Data Node:
# o TDS customized with ESGF access control filters
# o ORP

FROM esgfhub/esgf-tomcat:1.0

MAINTAINER Luca Cinquini <luca.cinquini@jpl.nasa.gov>

# default ESGF repository
ARG ESGF_REPO=http://distrib-coffee.ipsl.jussieu.fr/pub/esgf

# ESGF ORP
RUN mkdir -p /usr/local/tomcat/webapps/esg-orp

#COPY esgf-orp/esg-orp.war /usr/local/tomcat/webapps/esg-orp/esg-orp.war
ADD $ESGF_REPO/dist/devel/esg-orp/esg-orp.war /usr/local/tomcat/webapps/esg-orp/
RUN cd /usr/local/tomcat/webapps/esg-orp && \
    jar xvf esg-orp.war && \
    rm esg-orp.war && \
    chown -R tomcat:tomcat /usr/local/tomcat/webapps/esg-orp

# properties to read the Tomcat kesytore, used to sign the authentication cookie
# these values are the same for all ESGF nodes
COPY esgf-orp/conf/esg-orp.properties /usr/local/tomcat/webapps/esg-orp/WEB-INF/classes/esg-orp.properties

# TDS
RUN mkdir -p /usr/local/tomcat/webapps/thredds
#COPY thredds/thredds.war /usr/local/tomcat/webapps/thredds/thredds.war
ADD $ESGF_REPO/dist/devel/thredds/5.0/5.0.0/thredds.war /usr/local/tomcat/webapps/thredds/
RUN cd /usr/local/tomcat/webapps/thredds && \
    jar xvf thredds.war && \
    rm thredds.war && \
    chown -R tomcat:tomcat /usr/local/tomcat/webapps/thredds

# TDS memory configuration
COPY thredds/conf/threddsConfig.xml /esg/content/thredds/threddsConfig.xml

# TDS customized applicationContext.xml file with ESGF authorizer
COPY thredds/conf/applicationContext.xml /usr/local/tomcat/webapps/thredds/WEB-INF/applicationContext.xml

# TDS jars necessary to support ESGF security filters
COPY  thredds/jars/*  $CATALINA_HOME/webapps/thredds/WEB-INF/lib/

# TDS customized logging (uses DEBUG)
COPY thredds/conf/log4j2.xml /usr/local/tomcat/webapps/thredds/WEB-INF/classes/log4j2.xml

# data node scripts
COPY scripts/ /usr/local/bin/
RUN chmod +x /usr/local/bin/change_data_node_password.sh

# TDS test ESGF catalogs
# COPY esgf-content/thredds/ /esg/content/thredds/

# change ownership of content directory
RUN chown -R tomcat:tomcat /esg/content/thredds

# start container as non-privilged user
USER tomcat
ENTRYPOINT ["/usr/local/tomcat/bin/catalina.sh", "run"]
