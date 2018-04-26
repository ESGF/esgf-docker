#####
# Docker image for the ESGF publisher client
#####

FROM continuumio/miniconda:4.3.27

# Create an unprivileged user to use
ENV PUBLISH_USER publish
ENV PUBLISH_GROUP publish
# It is IMPORTANT that the UID is the same as the tomcat user in the TDS container
ENV PUBLISH_UID 1001
ENV PUBLISH_GID 1001
RUN groupadd -g $PUBLISH_GID $PUBLISH_GROUP && \
    useradd -M -g $PUBLISH_GID -s /sbin/nologin -u $PUBLISH_UID $PUBLISH_USER

# Set environment vars that control the behaviour
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
      ESGConfigParser==0.1.10 \
      esgprep==2.7.40

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
# Make the configuration files owned by the publish user and root group
# This means the container can be run by any user in the root group (e.g. on OpenShift)
RUN mkdir -p /esg/config/esgcet && \
    chown 1001:0 /esg/config/esgcet && \
    chmod 775 /esg/config/esgcet
COPY --chown=1001:0 conf /esg/config/esgcet
# Create the thredds content root owned by publish user and root group
RUN mkdir -p /esg/content/thredds/esgcet && \
    chown -R 1001:0 /esg/content/thredds && \
    chmod -R g+w /esg/content/thredds

WORKDIR /esg/config/esgcet

# Run as the publish user
USER 1001
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD ["run-publish-scripts"]
