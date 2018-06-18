#####
## Image for running the ESGF Auth client Django application
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

FROM python:2.7-slim AS esgf-auth-build

# Install git for checking out the source code and pulling dependencies
RUN apt-get update && \
    apt-get install -y git && \
    rm -rf /var/lib/apt/lists/*

# Clone the github repo and checkout the specified version
ARG ESGF_AUTH_GIT_VERSION=v1.0-alpha
RUN git clone https://github.com/ESGF/esgf-auth.git /application && \
    cd /application && \
    git checkout $ESGF_AUTH_GIT_VERSION && \
    rm -rf .git && \
    cd -

# Create wheels from the requirements
RUN mkdir /pip-wheels && \
    pip wheel --wheel-dir /pip-wheels git+https://github.com/philipkershaw/crypto-cookie.git && \
    pip wheel --wheel-dir /pip-wheels psycopg2 && \
    pip wheel --wheel-dir /pip-wheels -r /application/requirements.txt


#############
## Stage 2 ##
#############

FROM ${ESGF_HUB}/${ESGF_PREFIX}django:${ESGF_VERSION}

MAINTAINER Earth System Grid Federation <esgf-devel@lists.llnl.gov>

# Copy the application and wheels from the build stage
COPY --from=esgf-auth-build /application /application
COPY --from=esgf-auth-build /pip-wheels  /pip-wheels

# Install the dependency wheels (remove the wheels when we are done)
RUN pip install --no-index --find-links=/pip-wheels crypto-cookie && \
    pip install --no-index --find-links=/pip-wheels psycopg2 && \
    pip install --no-index --find-links=/pip-wheels -r /application/requirements.txt && \
    rm -rf /pip-wheels

# Because esgf-auth has no setup.py, we can't use pip install -e /application
# Instead, we add /application to the PYTHONPATH
ENV PYTHONPATH /application:$PYTHONPATH
ENV ESGF_AUTH_INSTALL_DIR /application

# Install ESGF Auth settings wrapper
COPY python/*.py /usr/local/lib/python2.7/site-packages/

# Install configuration files
# Ensure the config directory is owned by the Django user and root group
RUN mkdir -p /esg/config && chown 1001:0 /esg/config && chmod 775 /esg/config
COPY --chown=1001:0 --from=configuration /esg/config /esg/config
# Make sure the config interpolation runs first by giving it a low ordinal
COPY --from=configuration /opt/esgf-docker/scripts/interpolate-configs.sh /django-init.d/01-interpolate.sh
# Install the template auth config file
ENV ESGF_AUTH_CONFIG_FILE /esg/auth/esgf_auth_config.json
ENV ESGF_OAUTH2_SECRET_FILE /esg/auth/esgf_oauth2.json
# Ensure /esg/auth exists and is owned by the Django user and root group
RUN mkdir -p /esg/auth && chown 1001:0 /esg/auth && chmod 775 /esg/auth
COPY conf/esgf_auth_config.json.template "$ESGF_AUTH_CONFIG_FILE.template"
RUN echo "{}" > $ESGF_OAUTH2_SECRET_FILE
# This script interpolates the auth config files with additional environment variables
COPY scripts/auth-configure.sh /django-init.d/02-auth-configure.sh

# Run as the Django user unless otherwise specified
USER 1001

# The "command" is just the settings module to use
CMD ["esgf_auth_settings"]
