# ESGF Identity Provider node
# Implemented as Java web servlet application running inside Tomcat container.

FROM esgfhub/esgf-tomcat:1.2

MAINTAINER Luca Cinquini <luca.cinquini@jpl.nasa.gov>

# ESGF esg-idp web application
ARG ESGF_REPO=http://distrib-coffee.ipsl.jussieu.fr/pub/esgf

#ADD $ESGF_REPO/dist/devel/esgf-idp/esgf-idp.war /usr/local/tomcat/webapps/esgf-idp/
ADD esgf-idp.war /usr/local/tomcat/webapps/esgf-idp/
RUN cd /usr/local/tomcat/webapps/esgf-idp/ && \
    jar xvf esgf-idp.war && \
    rm esgf-idp.war && \
    chown -R tomcat:tomcat /usr/local/tomcat/webapps/esgf-idp

# Note: Tomcat startup configuration is inherited from esgf-tomcat container
