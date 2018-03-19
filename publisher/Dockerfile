#####
# Docker image for the ESGF publisher client
#####

ARG ESGF_HUB=cedadev
ARG ESGF_VERSION=latest

FROM continuumio/miniconda:4.3.27

# Set various environment vars that control the behaviour
ENV ESGINI /esg/config/esgcet/esg.ini
ENV UVCDAT_ANONYMOUS_LOG no

# Install gettext-base for envsubst
RUN apt-get update && \
    apt-get install -y gettext-base && \
    rm -rf /var/lib/apt/lists/*

# Install packages using conda and pip
RUN conda install -y -c conda-forge -c uvcdat \
      gcc_linux-64 \
      cdutil \
      lxml \
      requests \
      psycopg2 \
      decorator \
      Tempita \
      myproxyclient && \
    pip install \
      'SQLAlchemy==0.7.10' \
      sqlalchemy_migrate \
      esgprep

# Install the publisher client from GitHub
ARG ESG_PUBLISHER_VERSION=v3.2.7
RUN git clone https://github.com/ESGF/esg-publisher.git /application && \
    cd /application && \
    git checkout $ESG_PUBLISHER_VERSION && \
    cd src/python/esgcet && \
    python setup.py install && \
    cd

# Install entrypoint script
COPY scripts/* /usr/local/bin/
# Install configuration files and templates
COPY conf /esg/config/esgcet

WORKDIR /esg/config/esgcet
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD ["run-publish-scripts"]
