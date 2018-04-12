#####
## PostgreSQL container with ESGF databases pre-configured
#####

ARG ESGF_HUB=esgfhub
ARG ESGF_PREFIX=
ARG ESGF_VERSION=latest

FROM ${ESGF_HUB}/${ESGF_PREFIX}postgres:${ESGF_VERSION}

MAINTAINER Earth System Grid Federation <esgf-devel@lists.llnl.gov>

# Install the ESGF customisations

# This installs a script that checks our extra environment variables are present
RUN mkdir -p "${APP_DATA}/src/postgresql-pre-start"
COPY ./pre-start/* $APP_DATA/src/postgresql-pre-start/

# These need to run after the database is created - this means we must use the
# "start" hook rather than "init"
RUN mkdir -p "${APP_DATA}/src/postgresql-start"
COPY ./start/* $APP_DATA/src/postgresql-start/
