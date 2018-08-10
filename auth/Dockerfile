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


#############
## Stage 1 ##
#############

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

# Tell Django which settings module to use
ENV DJANGO_SETTINGS_MODULE esgf_auth_settings

# Install configuration files
# First, start with the /esg directory from esgf-configure
COPY --chown=1001:0 --from=configuration /esg /esg
# Install the default auth configuration
ENV ESGF_AUTH_CONFIG_FILE /esg/auth/esgf_auth_config.json
ENV ESGF_OAUTH2_SECRET_FILE /esg/auth/esgf_oauth2.json
COPY ./conf  /esg/auth/.defaults
# Correct the permissions on /esg/auth so that non-root users in the root group can write to it
RUN chown 1001:0 /esg/auth && chmod 755 /esg/auth

# Install initialisation scripts
COPY ./scripts /django-init.d

# Run as the Django user unless otherwise specified
USER 1001
