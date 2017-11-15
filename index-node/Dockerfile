# ESGF index node:  esgf-search application running inside Tomcat

FROM $ESGF_IMAGES_HUB/esgf-tomcat:$ESGF_VERSION
MAINTAINER Earth System Grid Federation <esgf-devel@lists.llnl.gov>

ARG ESGF_IMAGES_HUB=esgfhub
ARG ESGF_VERSION=devel

# ESGF esg-search web application

ARG ESGF_REPO=http://distrib-coffee.ipsl.jussieu.fr/pub/esgf
ADD $ESGF_REPO/dist/esg-search/esg-search.war /usr/local/tomcat/webapps/esg-search/
#COPY esg-search.war /usr/local/tomcat/webapps/.
RUN cd /usr/local/tomcat/webapps/esg-search/ && \
    jar xvf esg-search.war && \
    rm esg-search.war && \
    chown -R tomcat:tomcat /usr/local/tomcat/webapps/esg-search

COPY scripts/docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
COPY scripts/process_esgf_config_archive.sh /usr/local/bin/process_esgf_config_archive.sh
ENTRYPOINT /usr/local/bin/docker-entrypoint.sh
