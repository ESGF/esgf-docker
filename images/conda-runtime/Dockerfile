#####
## Base image for all runtime Conda images
##
## It is designed to have a pre-built Conda environment based on conda-builder
## copied into it using "COPY --from=<build image> /opt/conda /opt/conda"
##
## This avoids having build dependencies, such as compilers, git, etc. in
## the final image
#####

ARG ESGF_REPOSITORY_BASE=esgfhub
ARG ESGF_IMAGES_VERSION=latest
FROM ${ESGF_REPOSITORY_BASE}/base:${ESGF_IMAGES_VERSION}

USER root

# Configure environment
ENV CONDA_HOME /opt/conda
ENV PATH $CONDA_HOME/bin:$PATH
# Don't buffer stdout and stderr as it breaks realtime logging
ENV PYTHONUNBUFFERED 1

# Make an egg cache directory that is writable by the esg user
ENV PYTHON_EGG_CACHE /var/cache/python-eggs
RUN mkdir -p $PYTHON_EGG_CACHE && \
    chown -R $ESG_USER:$ESG_GROUP $PYTHON_EGG_CACHE

USER $ESG_UID
