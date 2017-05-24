# ESGF index node:  esgf-search application running inside Tomcat

FROM esgfhub/esgf-tomcat:1.2

MAINTAINER Luca Cinquini <luca.cinquini@jpl.nasa.gov>

# ESGF esg-search web application

ARG ESGF_REPO=http://distrib-coffee.ipsl.jussieu.fr/pub/esgf
ADD $ESGF_REPO/dist/devel/esg-search/esg-search.war /usr/local/tomcat/webapps/esg-search/
#COPY esg-search.war /usr/local/tomcat/webapps/.
RUN cd /usr/local/tomcat/webapps/esg-search/ && \
    jar xvf esg-search.war && \
    rm esg-search.war && \
    chown -R tomcat:tomcat /usr/local/tomcat/webapps/esg-search

# index node startup inherited from esgf-tomcat image
