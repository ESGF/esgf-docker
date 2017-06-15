# ESGF index node:  esgf-search application running inside Tomcat

FROM esgfhub/esgf-tomcat:1.1

MAINTAINER Luca Cinquini <luca.cinquini@jpl.nasa.gov>

# ESGF esg-search web application
# must have version 4.9.2+

ARG ESGF_REPO=http://distrib-coffee.ipsl.jussieu.fr/pub/esgf
ADD $ESGF_REPO/dist/devel/esg-search/esg-search.war /usr/local/tomcat/webapps/esg-search/
#COPY esg-search.war /usr/local/tomcat/webapps/.
RUN cd /usr/local/tomcat/webapps/esg-search/ && \
    jar xvf esg-search.war && \
    rm esg-search.war && \
    chown -R tomcat:tomcat /usr/local/tomcat/webapps/esg-search

COPY setenv.sh $CATALINA_HOME/bin

# Allow root group rwx permissions for tomcat
RUN chgrp -R 0 /usr/local/tomcat \
  && chmod -R g+rwX /usr/local/tomcat \
  && chgrp -R 0 /usr/local/apache-tomcat-${TOMCAT_VERSION} \
  && chmod -R g+rwX /usr/local/apache-tomcat-${TOMCAT_VERSION}
  
COPY config /esg/config
      
# run Tomcat as non-root user
USER tomcat
ENTRYPOINT ["/usr/local/tomcat/bin/catalina.sh", "run"]
