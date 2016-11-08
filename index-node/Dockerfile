# ESGF index node:  esgf-search application running inside Tomcat

FROM esgfhub/esgf-tomcat

MAINTAINER Luca Cinquini <luca.cinquini@jpl.nasa.gov>

# ESGF esg-search web application
# must have version 4.9.2+

ARG ESGF_REPO=http://distrib-coffee.ipsl.jussieu.fr/pub/esgf
ADD $ESGF_REPO/dist/devel/esg-search/esg-search.war /usr/local/tomcat/webapps/
#COPY esg-search.war /usr/local/tomcat/webapps/.

ENTRYPOINT ["/usr/local/tomcat/bin/catalina.sh", "run"]
