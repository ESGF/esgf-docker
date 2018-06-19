#####
## Image for running the ESGF CoG application
##
## To avoid including unnecessary build dependencies in the final image, we use
## a builder image to check out the code and build wheels for all our dependencies
#####

ARG ESGF_HUB=esgfhub
ARG ESGF_PREFIX=
ARG ESGF_VERSION=latest

# This build stage is required because COPY --from=$ARG is not supported
# https://github.com/moby/moby/issues/34482
FROM ${ESGF_HUB}/${ESGF_PREFIX}configure:${ESGF_VERSION} as configuration

FROM python:2.7-slim AS esgf-cog-build

# Install apt dependencies
#   * git so we can pull stuff from github
#   * build-essential for gcc
#   * libpq-dev for psycopg2
#   * libsqlite3-dev for pysqlite
#   * libssl-dev for globus-client
RUN apt-get update && \
    apt-get install -y git build-essential libpq-dev libsqlite3-dev libssl-dev && \
    rm -rf /var/lib/apt/lists/*

# Clone the github repo and checkout the specified version
ARG ESGF_COG_GIT_VERSION=v3.11
RUN git clone https://github.com/EarthSystemCoG/COG /application && \
    cd /application && \
    git checkout $ESGF_COG_GIT_VERSION && \
    rm -rf .git && \
    # It is important that the files are group-writable because of how static files are done in CoG
    chmod -R g+w . && \
    cd -

# Build wheels from the requirements, including additional dependencies from github
# This includes manually building the mkproxy executable for the globus-client
RUN mkdir /pip-wheels && \
    pip wheel --wheel-dir /pip-wheels -r /application/requirements.txt && \
    pip wheel --wheel-dir /pip-wheels --no-deps git+https://github.com/EarthSystemCoG/django-openid-auth.git && \
    git clone https://github.com/globusonline/transfer-api-client-python.git /globus-client && \
    pip wheel --wheel-dir /pip-wheels /globus-client && \
    make -C /globus-client/mkproxy


#############
## Stage 2 ##
#############

FROM ${ESGF_HUB}/${ESGF_PREFIX}django:${ESGF_VERSION}

MAINTAINER Earth System Grid Federation <esgf-devel@lists.llnl.gov>

# Install postgresql-client for shared objects for psycopg2
RUN mkdir -p /usr/share/man/man1 && \
    mkdir -p /usr/share/man/man7 && \
    apt-get update && \
    apt-get install -y postgresql-client && \
    rm -rf /var/lib/apt/lists/*

# setup CoG environment
ENV COG_DIR=/usr/local/cog
ENV COG_CONFIG_DIR=$COG_DIR/cog_config
ENV COG_INSTALL_DIR=$COG_DIR/cog_install
# Create any missing directories
# Make sure the config directory is owned by the Django user and root group
RUN mkdir -p $COG_INSTALL_DIR && chown 1001:0 $COG_INSTALL_DIR && chmod 775 $COG_INSTALL_DIR
RUN mkdir -p $COG_CONFIG_DIR && chown 1001:0 $COG_CONFIG_DIR && chmod 775 $COG_CONFIG_DIR

# Copy artifacts from the build stage
COPY --chown=1001:0 --from=esgf-cog-build /application $COG_INSTALL_DIR
COPY --from=esgf-cog-build /pip-wheels  /pip-wheels
COPY --from=esgf-cog-build /globus-client/mkproxy/mkproxy \
                           /usr/local/lib/python2.7/site-packages/globusonline/transfer/api_client/x509_proxy/

# Install the application + wheels (remove the wheels when we are done)
RUN pip install --no-index --find-links=/pip-wheels -r $COG_INSTALL_DIR/requirements.txt && \
    pip install --no-index --find-links=/pip-wheels django-openid-auth globusonline-transfer-api-client && \
    pip install --no-deps -e $COG_INSTALL_DIR && \
    rm -rf /pip-wheels

# Install CoG WSGI application and settings wrappers
COPY python/*.py /usr/local/lib/python2.7/site-packages/

# Install configuration files and scripts
# Ensure the config directory is owned by the Django user and root group
RUN mkdir -p /esg/config && chown 1001:0 /esg/config && chmod 775 /esg/config
COPY --chown=1001:0 --from=configuration /esg/config /esg/config
COPY --from=configuration /opt/esgf-docker/scripts /opt/esgf-docker/scripts
COPY conf/cog_settings.cfg.template $COG_CONFIG_DIR/
COPY scripts/* /django-init.d/

# Run as the Django user unless otherwise specified
USER 1001

# The "command" is the settings module to use
CMD ["cog_settings"]
