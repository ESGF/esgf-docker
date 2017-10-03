# ESGF Data Node: Docker image containing:
# o TDS customized with ESGF access control filters
# o ESGF publisher client (which needs access to the TDS file system)
# o ORP
# o Dashboard

FROM esgfhub/esgf-tomcat:devel-lc

MAINTAINER Luca Cinquini <luca.cinquini@jpl.nasa.gov>

# default ESGF repository
ARG ESGF_REPO=http://distrib-coffee.ipsl.jussieu.fr/pub/esgf

#============================================

# ESGF publisher client

# install library pre-requisites
RUN yum -y update; yum -y install libxml2-devel libxslt-devel; yum clean all

# install Anaconda
ENV CDAT_HOME=/usr/local/conda
RUN cd /tmp && rm -rf $CDAT_HOME && \
    wget --no-check-certificate https://repo.continuum.io/miniconda/Miniconda2-latest-Linux-x86_64.sh && \
    bash Miniconda2-latest-Linux-x86_64.sh -b -p $CDAT_HOME

# create CDAT virtual environment with Anaconda
ENV PATH=${CDAT_HOME}/bin:$PATH
RUN conda create -y -n esgf-pub -c conda-forge -c uvcdat cdutil

# activate virtual env and fetch some pre-requisites
RUN source ${CDAT_HOME}/bin/activate esgf-pub && \
    conda install -y -c conda-forge lxml requests psycopg2 decorator Tempita myproxyclient

# install other python pre-requisites
RUN source ${CDAT_HOME}/bin/activate esgf-pub && \
    pip install SQLAlchemy==0.7.10 && \
    pip install sqlalchemy_migrate && \
    pip install esgprep

# install ESGF publisher
# location: /usr/local/conda/envs/esgf-pub/
ENV ESG_PUBLISHER_VERSION=v3.2.2
RUN source ${CDAT_HOME}/bin/activate esgf-pub && \
    cd /tmp && \
    git clone https://github.com/ESGF/esg-publisher.git && \
    cd esg-publisher && \
    git checkout $ESG_PUBLISHER_VERSION && \
    cd src/python/esgcet && \
    python setup.py install

# env needed by Python client to trust the data node server certicate
ENV SSL_CERT_DIR /etc/grid-security/certificates
ENV ESGINI /esg/config/esgcet/esg.ini

#==========================================================

# ESGF ORP
RUN mkdir -p /usr/local/tomcat/webapps/esg-orp

#COPY esgf-orp/esg-orp.war /usr/local/tomcat/webapps/esg-orp/esg-orp.war
ADD $ESGF_REPO/dist/esg-orp/esg-orp.war /usr/local/tomcat/webapps/esg-orp/
RUN cd /usr/local/tomcat/webapps/esg-orp && \
    jar xvf esg-orp.war && \
    rm esg-orp.war && \
    chown -R tomcat:tomcat /usr/local/tomcat/webapps/esg-orp

# properties to read the Tomcat kesytore, used to sign the authentication cookie
# these values are the same for all ESGF nodes
COPY esgf-orp/conf/esg-orp.properties /usr/local/tomcat/webapps/esg-orp/WEB-INF/classes/esg-orp.properties

#=============================================

# ESGF OLD NODE MANAGER
# uset to extract dependency jars
RUN mkdir -p /usr/local/tomcat/webapps/esgf-node-manager
ADD $ESGF_REPO/dist/esgf-node-manager/esgf-node-manager.war /usr/local/tomcat/webapps/esgf-node-manager/
RUN cd /usr/local/tomcat/webapps/esgf-node-manager/ && \
    jar xvf esgf-node-manager.war

#============================================

# TDS

RUN mkdir -p /usr/local/tomcat/webapps/thredds
#COPY thredds/thredds.war /usr/local/tomcat/webapps/thredds/thredds.war
ADD $ESGF_REPO/dist/thredds/5.0/5.0.2/thredds.war /usr/local/tomcat/webapps/thredds/
RUN cd /usr/local/tomcat/webapps/thredds && \
    jar xvf thredds.war && \
    rm thredds.war && \
    chown -R tomcat:tomcat /usr/local/tomcat/webapps/thredds

# TDS configuration root
RUN mkdir -p /esg/content/thredds

# TDS memory configuration
COPY thredds/conf/threddsConfig.xml  /esg/content/thredds/threddsConfig.xml

# ESGF root catalog
COPY thredds/conf/catalog.xml /esg/content/thredds/catalog.xml-esgcet
#COPY thredds/conf/esgcet/catalog.xml /esg/content/thredds/esgcet/catalog.xml
RUN mkdir -p /esg/content/thredds/esgcet

# TDS customized applicationContext.xml file with ESGF authorizer
COPY thredds/conf/applicationContext.xml /usr/local/tomcat/webapps/thredds/WEB-INF/applicationContext.xml

# TDS jars necessary to support ESGF security filters
# some jars are retrieved from the ESGF repository
# other jars are copied from the unpacked ORP or NM distributions
#COPY  thredds/jars/*  $CATALINA_HOME/webapps/thredds/WEB-INF/lib/

ADD $ESGF_REPO/dist/filters/XSGroupRole-1.0.0.jar $CATALINA_HOME/webapps/thredds/WEB-INF/lib/XSGroupRole-1.0.0.jar
ADD $ESGF_REPO/dist/filters/commons-httpclient-3.1.jar $CATALINA_HOME/webapps/thredds/WEB-INF/lib/commons-httpclient-3.1.jar
ADD $ESGF_REPO/dist/filters/commons-lang-2.6.jar $CATALINA_HOME/webapps/thredds/WEB-INF/lib/commons-lang-2.6.jar
ADD $ESGF_REPO/dist/esg-orp/esg-orp-2.9.3.jar $CATALINA_HOME/webapps/thredds/WEB-INF/lib/esg-orp-2.9.6.jar
ADD $ESGF_REPO/dist/esgf-node-manager/esgf-node-manager-common-1.0.0.jar $CATALINA_HOME/webapps/thredds/WEB-INF/lib/esgf-node-manager-common-1.0.0.jar
ADD $ESGF_REPO/dist/esgf-node-manager/esgf-node-manager-filters-1.0.0.jar $CATALINA_HOME/webapps/thredds/WEB-INF/lib/esgf-node-manager-filters-1.0.0.jar
ADD $ESGF_REPO/dist/esgf-security/esgf-security-2.7.10.jar $CATALINA_HOME/webapps/thredds/WEB-INF/lib/esgf-security-2.7.15.jar
ADD $ESGF_REPO/dist/filters/jdom-legacy-1.1.3.jar $CATALINA_HOME/webapps/thredds/WEB-INF/lib/jdom-legacy-1.1.3.jar
ADD $ESGF_REPO/dist/filters/opensaml-2.3.2.jar $CATALINA_HOME/webapps/thredds/WEB-INF/lib/opensaml-2.3.2.jar
ADD $ESGF_REPO/dist/filters/openws-1.3.1.jar $CATALINA_HOME/webapps/thredds/WEB-INF/lib/openws-1.3.1.jar
ADD $ESGF_REPO/dist/filters/xmltooling-1.2.2.jar $CATALINA_HOME/webapps/thredds/WEB-INF/lib/xmltooling-1.2.2.jar

RUN cp /usr/local/tomcat/webapps/esg-orp/WEB-INF/lib/serializer-2.9.1.jar $CATALINA_HOME/webapps/thredds/WEB-INF/lib/serializer-2.9.1.jar
RUN cp /usr/local/tomcat/webapps/esg-orp/WEB-INF/lib/velocity-1.5.jar $CATALINA_HOME/webapps/thredds/WEB-INF/lib/velocity-1.5.jar
RUN cp /usr/local/tomcat/webapps/esg-orp/WEB-INF/lib/xalan-2.7.2.jar $CATALINA_HOME/webapps/thredds/WEB-INF/lib/xalan-2.7.2.jar
RUN cp /usr/local/tomcat/webapps/esg-orp/WEB-INF/lib/xercesImpl-2.10.0.jar $CATALINA_HOME/webapps/thredds/WEB-INF/lib/xercesImpl-2.10.0.jar
RUN cp /usr/local/tomcat/webapps/esg-orp/WEB-INF/lib/xml-apis-1.4.01.jar $CATALINA_HOME/webapps/thredds/WEB-INF/lib/xml-apis-1.4.01.jar
RUN cp /usr/local/tomcat/webapps/esg-orp/WEB-INF/lib/xmlsec-1.4.2.jar $CATALINA_HOME/webapps/thredds/WEB-INF/lib/xmlsec-1.4.2.jar
RUN cp /usr/local/tomcat/webapps/esg-orp/WEB-INF/lib/commons-io-2.4.jar $CATALINA_HOME/webapps/thredds/WEB-INF/lib/commons-io-2.4.jar
#RUN cp /usr/local/tomcat/webapps/esg-orp/WEB-INF/lib/jcl-over-slf4j-1.6.4.jar $CATALINA_HOME/webapps/thredds/WEB-INF/lib/jcl-over-slf4j-1.6.4.jar
#RUN cp /usr/local/tomcat/webapps/esg-orp/WEB-INF/lib/slf4j-api-1.6.4.jar $CATALINA_HOME/webapps/thredds/WEB-INF/lib/slf4j-api-1.6.4.jar
#RUN cp /usr/local/tomcat/webapps/esg-orp/WEB-INF/lib/slf4j-log4j12-1.6.4.jar $CATALINA_HOME/webapps/thredds/WEB-INF/lib/slf4j-log4j12-1.6.4.jar
#RUN cp /usr/local/tomcat/webapps/esg-orp/WEB-INF/lib/log4j-api-2.6.2.jar $CATALINA_HOME/webapps/thredds/WEB-INF/lib/log4j-api-2.6.2.jar
#RUN cp /usr/local/tomcat/webapps/esg-orp/WEB-INF/lib/log4j-core-2.6.2.jar $CATALINA_HOME/webapps/thredds/WEB-INF/lib/log4j-core-2.6.2.jar
#RUN cp /usr/local/tomcat/webapps/esg-orp/WEB-INF/lib/log4j-slf4j-impl-2.6.2.jar $CATALINA_HOME/webapps/thredds/WEB-INF/lib/log4j-slf4j-impl-2.6.2.jar
#RUN cp /usr/local/tomcat/webapps/esg-orp/WEB-INF/lib/log4j-web-2.6.2.jar $CATALINA_HOME/webapps/thredds/WEB-INF/lib/log4j-web-2.6.2.jar

RUN cp /usr/local/tomcat/webapps/esgf-node-manager/WEB-INF/lib/commons-dbcp-1.4.jar $CATALINA_HOME/webapps/thredds/WEB-INF/lib/commons-dbcp-1.4.jar
RUN cp /usr/local/tomcat/webapps/esgf-node-manager/WEB-INF/lib/commons-dbutils-1.3.jar $CATALINA_HOME/webapps/thredds/WEB-INF/lib/commons-dbutils-1.3.jar
RUN cp /usr/local/tomcat/webapps/esgf-node-manager/WEB-INF/lib/commons-pool-1.5.4.jar $CATALINA_HOME/webapps/thredds/WEB-INF/lib/commons-pool-1.5.4.jar
RUN cp /usr/local/tomcat/webapps/esgf-node-manager/WEB-INF/lib/postgresql-8.4-703.jdbc3.jar $CATALINA_HOME/webapps/thredds/WEB-INF/lib/postgresql-8.4-703.jdbc3.jar

# TDS customized logging (uses DEBUG)
COPY thredds/conf/log4j2.xml /usr/local/tomcat/webapps/thredds/WEB-INF/classes/log4j2.xml

# data node scripts
COPY scripts/ /usr/local/bin/

# TDS test ESGF catalogs
# COPY esgf-content/thredds/ /esg/content/thredds/

# TDS catalogs location
#RUN mkdir -p /esg/content/thredds/esgcet

# change ownership of content directory
RUN chown -R tomcat:tomcat  /esg/content/thredds/
# change ownership of source directory
RUN chown -R tomcat:tomcat $CATALINA_HOME/webapps/thredds

# cleanup
RUN rm -rf /usr/local/tomcat/webapps/esgf-node-manager/

#===========================================

# Dashboard
# note: dashboard application accesses the postgres database via credentials 
# stored in /esg/config/esg.ini and /esg/config/.esg_pg_pass

ENV DASHBOARD_HOME /usr/local/esgf-dashboard-ip

# library dependencies
RUN yum -y install epel-release
RUN yum install -y curl-devel \
                   GeoIP \
                   GeoIP-devel

# install additional GeoLiteCity database
#COPY dashboard/GeoLiteCity.dat.gz /tmp
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
COPY dashboard/scripts/ /usr/local/bin/
RUN /usr/local/bin/dashboard_ipservice.sh

# create non-privileged user to run the dashboard application
RUN groupadd dashboard && \
    useradd -s /sbin/nologin -g dashboard -d /usr/local/dashboard dashboard && \
    chown -R dashboard:dashboard /usr/local/esgf-dashboard-ip
RUN chmod a+w /var/run

# install the supervisor configuration for the dashboard
# must start esgf-dashboard-ip in the foreground as non-daemon (no '&' to background the process)
ADD dashboard/scripts/ip.service $DASHBOARD_HOME/bin/ip.service
ADD dashboard/conf/supervisord.dashboard.conf /etc/supervisor/conf.d/supervisord.dashboard.conf 
RUN mkdir -p $DASHBOARD_HOME/logs

#===========================================

# ESGF-AUTH APPLICATION

# library dependencies
RUN yum -y update; yum -y install libffi-devel; yum clean all

# create python virtual environment
RUN mkdir -p /usr/local/esgf-auth && \
    cd /usr/local/esgf-auth && \
    virtualenv venv

# install source code
RUN mkdir -p /usr/local/esgf-auth/src

# install crypto cookie
RUN cd /usr/local/esgf-auth && \
    source venv/bin/activate && \
    cd src && \
    git clone https://github.com/philipkershaw/crypto-cookie.git && \
    cd /usr/local/esgf-auth/src/crypto-cookie && \
    python setup.py install

# install esgf-auth
RUN cd /usr/local/esgf-auth && \
    source venv/bin/activate && \
    cd src && \
    git clone https://github.com/lukaszlacinski/esgf-auth.git && \
    cd /usr/local/esgf-auth/src/esgf-auth && \
    pip install -r requirements.txt && \
    pip install paste && \
    python manage.py migrate

#===========================================

# startup configuration inherited from esgf-tomcat image
CMD ["supervisord", "--nodaemon", "-c", "/etc/supervisord.conf"]
