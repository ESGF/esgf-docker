# ESGF Identity Provider node
# Implemented as Java web servlet application running inside Tomcat container.

FROM esgfhub/esgf-tomcat:1.0

MAINTAINER Luca Cinquini <luca.cinquini@jpl.nasa.gov>

# ESGF esg-idp web application
ARG ESGF_REPO=http://distrib-coffee.ipsl.jussieu.fr/pub/esgf

# FIXME
ADD $ESGF_REPO/dist/devel/esgf-idp/esgf-idp.war /usr/local/tomcat/webapps/
#COPY esgf-idp.war /usr/local/tomcat/webapps

ENTRYPOINT ["/usr/local/tomcat/bin/catalina.sh", "run"]
