# ESGF Data Node: Docker image containing:
# o TDS customized with ESGF access control filters
# o ESGF publisher client (which needs access to the TDS file system)
# o ORP

FROM esgfhub/esgf-tomcat:1.1

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
# location: /usr/local/conda/lib/python2.7/site-packages/esgcet-3.0.1-py2.7.egg
ENV ESG_PUBLISHER_VERSION=v3.0.1
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

COPY esgf-orp/esg-orp.war /usr/local/tomcat/webapps/esg-orp/esg-orp.war
#ADD $ESGF_REPO/dist/devel/esg-orp/esg-orp.war /usr/local/tomcat/webapps/esg-orp/
RUN cd /usr/local/tomcat/webapps/esg-orp && \
    jar xvf esg-orp.war && \
    rm esg-orp.war && \
    chown -R tomcat:tomcat /usr/local/tomcat/webapps/esg-orp

# properties to read the Tomcat kesytore, used to sign the authentication cookie
# these values are the same for all ESGF nodes
COPY esgf-orp/conf/esg-orp.properties /usr/local/tomcat/webapps/esg-orp/WEB-INF/classes/esg-orp.properties

#=============================================

# TDS

RUN mkdir -p /usr/local/tomcat/webapps/thredds
COPY thredds/thredds.war /usr/local/tomcat/webapps/thredds/thredds.war
#ADD $ESGF_REPO/dist/devel/thredds/5.0/5.0.0/thredds.war /usr/local/tomcat/webapps/thredds/
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
COPY  thredds/jars/*  $CATALINA_HOME/webapps/thredds/WEB-INF/lib/

# TDS customized logging (uses DEBUG)
COPY thredds/conf/log4j2.xml /usr/local/tomcat/webapps/thredds/WEB-INF/classes/log4j2.xml

# data node scripts
COPY scripts/ /usr/local/bin/
RUN chmod +x /usr/local/bin/change_data_node_password.sh

# TDS test ESGF catalogs
# COPY esgf-content/thredds/ /esg/content/thredds/

# TDS catalogs location
#RUN mkdir -p /esg/content/thredds/esgcet

# change ownership of content directory
RUN chown -R tomcat:tomcat  /esg/content/thredds/

#===========================================

# Dashboard

# library dependencies
RUN yum -y install epel-release
RUN yum install -y curl-devel \
                   GeoIP \
                   GeoIP-devel

# must write postgress password for batch access
RUN echo 'esgf-postgres:5432:esgcet:dbsuper:changeit' >> /root/.pgpass \
    && chmod 0600 /root/.pgpass


# install esgf-stats-api war file
COPY dashboard/esgf-stats-api.war /usr/local/tomcat/webapps/esgf-stats-api/esgf-stats-api.war
#ADD $ESGF_REPO/dist/devel/esgf-stats-api/esgf-stats-api.war /usr/local/tomcat/webapps/esgf-stats-api/esgf-stats-api.war
RUN cd /usr/local/tomcat/webapps/esgf-stats-api && \
    jar xvf esgf-stats-api.war && \
    rm esgf-stats-api.war && \
    chown -R tomcat:tomcat /usr/local/tomcat/webapps/esgf-stats-api

# execute dashboard installation script
COPY dashboard/scripts/ /usr/local/bin/
RUN /usr/local/bin/dashboard_ipservice.sh

# install additional GeoLiteCity database
COPY dashboard/GeoLiteCity.dat.gz /tmp
RUN mkdir -p /usr/local/geoip/share/GeoIP && \
     cd /tmp && \
     gunzip -c GeoLiteCity.dat.gz > /usr/local/geoip/share/GeoIP/GeoLiteCity.dat

#===========================================

# start container as non-privilged user
USER tomcat
ENTRYPOINT ["/usr/local/tomcat/bin/catalina.sh", "run"]
