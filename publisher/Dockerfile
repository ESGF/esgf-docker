# Docker image containing the ESGF publisher client

ARG ESGF_IMAGES_HUB=esgfhub
ARG ESGF_VERSION=devel

FROM $ESGF_IMAGES_HUB/esgf-node:$ESGF_VERSION

MAINTAINER ESGF <esgf-devel@lists.llnl.gov>

# default ESGF repository
ARG ESGF_REPO=http://distrib-coffee.ipsl.jussieu.fr/pub/esgf

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
ENV ESG_PUBLISHER_VERSION=v3.2.7
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

# startup scripts
COPY scripts/ /usr/local/bin/

ENTRYPOINT /usr/local/bin/docker-entrypoint.sh
