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
# and creates the esgf_security_data.sql start file
COPY ./pre-start/* $APP_DATA/src/postgresql-pre-start/

# Install schemas to be used to populate database
COPY ./start/esgf_security.sql $APP_DATA/src/postgresql-start/01-esgf_security.sql
