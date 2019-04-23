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

# Install dependencies using conda
# NOTE: esgprep has very specific version requirements
ARG CDAT_LABEL_CHANNEL=cdat/label/80
RUN conda install -y -c $CDAT_LABEL_CHANNEL -c conda-forge -c cdat \
      psycopg2-binary \
      lxml \
      cdutil \
      gcc_linux-64 \
      'requests==2.20.0' \
      'netCDF4==1.4.0'

# Make the conda-installed gcc available as gcc
#   See https://conda.io/docs/user-guide/tasks/build-packages/compiler-tools.html
RUN ln -s /opt/conda/bin/x86_64-conda_cos6-linux-gnu-gcc /usr/local/bin/gcc

# Install the publisher client from GitHub
# TODO: REMOVE PATCH
# Before installing, patch the publisher to fix this issue - https://github.com/ESGF/esg-publisher/issues/133
ARG ESG_PUBLISHER_VERSION=v3.5.5
RUN git clone https://github.com/ESGF/esg-publisher.git /application && \
    cd /application && \
    git checkout $ESG_PUBLISHER_VERSION && \
    cd src/python/esgcet && \
    sed -i \
      "s/config.get('DEFAULT', 'hessian_service_certs_location')/getConfig().get('DEFAULT', 'hessian_service_certs_location')/g" \
      ./esgcet/publish/utility.py && \
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
