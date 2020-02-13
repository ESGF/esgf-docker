#####
## Base image for all runtime Conda images
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

# Copy the conda environment from the builder image
ONBUILD COPY --from=builder /opt/conda /opt/conda

USER $ESG_UID
