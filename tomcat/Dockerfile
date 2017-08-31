# ESGF node with Tomcat configured for ESGF services:
# o Tomcat keystore, truststore files located in /esg/config/tomcat
# o startup with ESGF specific env variables defined in bin/setenv.sh

FROM esgfhub/esgf-node:devel

MAINTAINER Luca Cinquini <luca.cinquini@jpl.nasa.gov>

# Tomcat 8
ENV TOMCAT_VERSION 8.5.20

RUN wget -O /tmp/apache-tomcat-${TOMCAT_VERSION}.tar.gz http://mirror.reverse.net/pub/apache/tomcat/tomcat-8/v${TOMCAT_VERSION}/bin/apache-tomcat-${TOMCAT_VERSION}.tar.gz && \
    cd /usr/local && tar xzf /tmp/apache-tomcat-${TOMCAT_VERSION}.tar.gz && \
    ln -s /usr/local/apache-tomcat-${TOMCAT_VERSION} /usr/local/tomcat && \
    rm /tmp/apache-tomcat-${TOMCAT_VERSION}.tar.gz
ENV CATALINA_HOME /usr/local/tomcat

# remove Tomcat example applications
RUN cd /usr/local/tomcat/webapps && \
    rm -rf docs examples host-manager manager

# copy custom configuration
# server.xml: includes references to keystore, truststore in /esg/config/tomcat
# context.xml: increases the Tomcat cache to avoid flood of warning messages
COPY conf/server.xml /usr/local/tomcat/conf/server.xml
COPY conf/context.xml /usr/local/tomcat/conf/context.xml
COPY certs/ /esg/config/tomcat/

# custom env variables for starting Tomcat
COPY conf/setenv.sh $CATALINA_HOME/bin

# create non-privilged user to run Tomcat
RUN groupadd tomcat
RUN useradd -s /sbin/nologin -g tomcat -d /usr/local/tomcat tomcat
RUN chown -R tomcat:tomcat /usr/local/apache-tomcat-${TOMCAT_VERSION}
RUN chmod 775 /usr/local/tomcat/webapps

EXPOSE 8080
EXPOSE 8443

# startup
COPY conf/supervisord.tomcat.conf /etc/supervisor/conf.d/supervisord.tomcat.conf
CMD ["supervisord", "--nodaemon", "-c", "/etc/supervisord.conf"]
