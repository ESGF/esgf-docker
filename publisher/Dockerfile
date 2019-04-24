#####
# Docker image for the ESGF publisher client
#####

ARG ESGF_HUB=esgfhub
ARG ESGF_PREFIX=
ARG ESGF_VERSION=latest

# This build stage is required because COPY --from=$ARG is not supported
# https://github.com/moby/moby/issues/34482
FROM ${ESGF_HUB}/${ESGF_PREFIX}configure:${ESGF_VERSION} as configuration


FROM continuumio/miniconda

# Create an unprivileged user to use
ENV PUBLISH_USER publish
ENV PUBLISH_GROUP publish
# It is IMPORTANT that the UID is the same as the tomcat user in the TDS container
ENV PUBLISH_UID 1001
ENV PUBLISH_GID 1001
RUN groupadd -g $PUBLISH_GID $PUBLISH_GROUP && \
    useradd -M -g $PUBLISH_GID -s /sbin/nologin -u $PUBLISH_UID $PUBLISH_USER

# Set environment vars that control the behaviour
ENV ESGINI /esg/config/esgcet/esg.ini
ENV UVCDAT_ANONYMOUS_LOG no

# Install dependencies
# NOTE: esgprep has very specific version requirements
#   netCDF4 1.4.0 must be installed using pip as it conflicts with the
#   dependency specification for later versions of libcdms
# Also make the conda-installed gcc available as gcc
#   See https://conda.io/docs/user-guide/tasks/build-packages/compiler-tools.html
ARG CDAT_LABEL_CHANNEL=cdat/label/v81
RUN conda install -y -c conda-forge -c $CDAT_LABEL_CHANNEL \
      gcc_linux-64 \
      lxml \
      cdtime \
      cdms2 \
      'psycopg2<2.7' \
      'requests==2.20.0' && \
    pip install \
      'netCDF4==1.4.0' && \
    ln -s /opt/conda/bin/x86_64-conda_cos6-linux-gnu-gcc /usr/local/bin/gcc

# Install the publisher client from GitHub
ARG ESG_PUBLISHER_VERSION=v3.6.3
RUN git clone https://github.com/ESGF/esg-publisher.git /application && \
    cd /application && \
    git checkout $ESG_PUBLISHER_VERSION && \
    cd src/python/esgcet && \
    python setup.py install && \
    cd

# Install entrypoint script
COPY scripts/* /usr/local/bin/
# Install configuration files and templates
# Start with the /esg/bin directory from esgf-configure
COPY --chown=1001:0 --from=configuration /esg/bin /esg/bin
# Make the configuration files owned by the publish user and root group
# This means the container can be run by any user in the root group (e.g. on OpenShift)
COPY --chown=1001:0 ./conf /esg/config/esgcet/.defaults
RUN chown 1001:0 /esg/config/esgcet && chmod 775 /esg/config/esgcet
# Create the thredds content root owned by publish user and root group
RUN mkdir -p /esg/content/thredds/esgcet && \
    chown -R 1001:0 /esg/content/thredds && \
    chmod -R g+w /esg/content/thredds

WORKDIR /esg/config/esgcet

# Run as the publish user
USER 1001
# esgprep requires that the USER environment variable is set
ENV USER $PUBLISH_USER
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD ["run-publish-scripts"]
