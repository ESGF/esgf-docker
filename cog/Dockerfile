#####
## Image for running the ESGF CoG application
##
## To avoid including unnecessary build dependencies in the final image, we use
## a builder image to check out the code and build wheels for all our dependencies
#####

ARG ESGF_DJANGO_VERSION=latest

FROM python:2.7-slim AS esgf-cog-build

# Install apt dependencies
#   * git so we can pull stuff from github
#   * build-essential for gcc
#   * libpq-dev for psycopg2
#   * libsqlite3-dev for pysqlite
RUN apt-get update && \
    apt-get install -y git build-essential libpq-dev libsqlite3-dev && \
    rm -rf /var/lib/apt/lists/*

# Clone the github repo and checkout the specified version
ARG ESGF_COG_GIT_VERSION=master
RUN git clone https://github.com/EarthSystemCoG/COG /application && \
    cd /application && \
    git checkout $ESGF_COG_GIT_VERSION && \
    rm -rf .git && \
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

FROM cedadev/esgf-django:${ESGF_DJANGO_VERSION}

MAINTAINER Earth System Grid Federation <esgf-devel@lists.llnl.gov>

# Install gettext for envsubst to allow environment variable substitution in config files
# Install postgresql shared objects for psycopg2
RUN mkdir -p /usr/share/man/man1 && \
    mkdir -p /usr/share/man/man7 && \
    apt-get update && \
    apt-get install -y gettext-base postgresql-client && \
    rm -rf /var/lib/apt/lists/*

# setup CoG environment
ENV COG_DIR=/usr/local/cog
ENV COG_CONFIG_DIR=$COG_DIR/cog_config
ENV COG_INSTALL_DIR=$COG_DIR/cog_install
# Create any missing directories
RUN mkdir -p $COG_CONFIG_DIR
RUN mkdir -p $COG_INSTALL_DIR

# Copy artifacts from the build stage
COPY --from=esgf-cog-build /application $COG_INSTALL_DIR
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
COPY templates/cog_settings.cfg $COG_CONFIG_DIR/cog_settings.cfg.template
COPY templates/esgf_idp.xml /esg/config/esgf_idp.xml.template
COPY conf/* /esg/config/
COPY scripts/* /django-init.d/

# The "command" is the settings module to use
CMD ["cog_settings"]
