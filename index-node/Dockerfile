# ESGF index node:  esgf-search application running inside Tomcat

ARG ESGF_IMAGES_HUB=esgfhub
ARG ESGF_VERSION=devel

FROM $ESGF_IMAGES_HUB/esgf-tomcat:$ESGF_VERSION

MAINTAINER Luca Cinquini <luca.cinquini@jpl.nasa.gov>

# ESGF esg-search web application

ARG ESGF_REPO=http://distrib-coffee.ipsl.jussieu.fr/pub/esgf
ADD $ESGF_REPO/dist/esg-search/esg-search.war /usr/local/tomcat/webapps/esg-search/
#COPY esg-search.war /usr/local/tomcat/webapps/.
RUN cd /usr/local/tomcat/webapps/esg-search/ && \
    jar xvf esg-search.war && \
    rm esg-search.war && \
    chown -R tomcat:tomcat /usr/local/tomcat/webapps/esg-search

# index node startup configuration inherited from esgf-tomcat image
CMD ["supervisord", "--nodaemon", "-c", "/etc/supervisord.conf"]
