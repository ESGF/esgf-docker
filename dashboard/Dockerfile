# Docker image containing 
# the ESGF Dashboard and the esgf-stats web application

# Note: dashboard application accesses the postgres database via credentials
# stored in /esg/config/esg.ini and /esg/config/.esg_pg_pass

ARG ESGF_IMAGES_HUB=esgfhub
ARG ESGF_VERSION=devel

FROM $ESGF_IMAGES_HUB/esgf-tomcat:$ESGF_VERSION

MAINTAINER ESGF <esgf-devel@lists.llnl.gov>

# default ESGF repository
ARG ESGF_REPO=http://distrib-coffee.ipsl.jussieu.fr/pub/esgf

ENV DASHBOARD_HOME /usr/local/esgf-dashboard-ip

# install library dependencies
RUN yum -y install epel-release
RUN yum install -y libxml2-devel libxslt-devel \
                   curl-devel \
                   GeoIP \
                   GeoIP-devel
RUN yum clean all

# install additional GeoLiteCity database
ADD $ESGF_REPO/dist/geoip/GeoLiteCity.dat.gz /tmp/GeoLiteCity.dat.gz
RUN mkdir -p /usr/local/geoip/share/GeoIP && \
     cd /tmp && \
     gunzip -c GeoLiteCity.dat.gz > /usr/local/geoip/share/GeoIP/GeoLiteCity.dat

# install esgf-stats-api war file
#COPY dashboard/esgf-stats-api.war /usr/local/tomcat/webapps/esgf-stats-api/esgf-stats-api.war
ADD $ESGF_REPO/dist/esgf-stats-api/esgf-stats-api.war /usr/local/tomcat/webapps/esgf-stats-api/esgf-stats-api.war
RUN cd /usr/local/tomcat/webapps/esgf-stats-api && \
    jar xvf esgf-stats-api.war && \
    rm esgf-stats-api.war && \
    chown -R tomcat:tomcat /usr/local/tomcat/webapps/esgf-stats-api

# execute dashboard installation script (without the postgres schema)
COPY scripts/ /usr/local/bin/
RUN mkdir $DASHBOARD_HOME && \
    /usr/local/bin/dashboard_ipservice.sh

# create non-privileged user to run the dashboard application
RUN groupadd dashboard && \
    useradd -s /sbin/nologin -g dashboard -d /usr/local/dashboard dashboard && \
    chown -R dashboard:dashboard /usr/local/esgf-dashboard-ip
RUN chmod a+w /var/run

# install the supervisor configuration for the dashboard
# must start esgf-dashboard-ip in the foreground as non-daemon (no '&' to background the process)
ADD scripts/ip.service $DASHBOARD_HOME/bin/ip.service
ADD conf/supervisord.dashboard.conf /etc/supervisor/conf.d/supervisord.dashboard.conf 
RUN mkdir -p $DASHBOARD_HOME/logs

ENTRYPOINT /usr/local/bin/docker-entrypoint.sh
