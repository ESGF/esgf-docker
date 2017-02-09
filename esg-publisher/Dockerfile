# ESGF node with esgf-publisher application

FROM esgfhub/esgf-node:1.0

MAINTAINER Luca Cinquini <luca.cinquini@jpl.nasa.gov>

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

# copy configuration files
COPY config/esgcet /esg/config/esgcet
ENV ESGINI /esg/config/esgcet/esg.ini

# temporary: copy pre-generated Globus certificate
COPY config/globus/certificate-file /tmp/certificate-file

# activate publisher environment
RUN source ${CDAT_HOME}/bin/activate esgf-pub

# keep container running
CMD ["tail", "-f", "/dev/null"]
