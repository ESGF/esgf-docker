# ESGF Identity Provider node
# Implemented as Java web servlet application running inside Tomcat container.

FROM esgfhub/esgf-tomcat:1.1

MAINTAINER Luca Cinquini <luca.cinquini@jpl.nasa.gov>

# ESGF esg-idp web application
ARG ESGF_REPO=http://distrib-coffee.ipsl.jussieu.fr/pub/esgf

# FIXME
ADD $ESGF_REPO/dist/devel/esgf-idp/esgf-idp.war /usr/local/tomcat/webapps/esgf-idp/
#COPY esgf-idp.war /usr/local/tomcat/webapps/esgf-idp/
RUN cd /usr/local/tomcat/webapps/esgf-idp/ && \
    jar xvf esgf-idp.war && \
    rm esgf-idp.war && \
    chown -R tomcat:tomcat /usr/local/tomcat/webapps/esgf-idp

# run Tomcat as non-privileged user
USER tomcat
ENTRYPOINT ["/usr/local/tomcat/bin/catalina.sh", "run"]
