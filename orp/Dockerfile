# Docker image containing the ESGF Openid Relying Party (ORP)

FROM $ESGF_IMAGES_HUB/esgf-tomcat:$ESGF_VERSION
MAINTAINER Earth System Grid Federation <esgf-devel@lists.llnl.gov>

ARG ESGF_IMAGES_HUB=esgfhub
ARG ESGF_VERSION=devel

# default ESGF repository
ARG ESGF_REPO=http://distrib-coffee.ipsl.jussieu.fr/pub/esgf

RUN mkdir -p /usr/local/tomcat/webapps/esg-orp

ADD $ESGF_REPO/dist/esg-orp/esg-orp.war /usr/local/tomcat/webapps/esg-orp/
RUN cd /usr/local/tomcat/webapps/esg-orp && \
    jar xvf esg-orp.war && \
    rm esg-orp.war && \
    chown -R tomcat:tomcat /usr/local/tomcat/webapps/esg-orp

# properties to read the Tomcat kesytore, used to sign the authentication cookie
# these values are the same for all ESGF nodes
COPY conf/esg-orp.properties /usr/local/tomcat/webapps/esg-orp/WEB-INF/classes/esg-orp.properties

# startup scripts
COPY scripts/ /usr/local/bin/
ENTRYPOINT /usr/local/bin/docker-entrypoint.sh
