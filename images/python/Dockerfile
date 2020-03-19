#####
## Base image for all Python images using conda
##
## This Dockerfile is used to build the python2 and python3 images
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

# Make an egg cache directory that is writable by the esgf user
ENV PYTHON_EGG_CACHE /var/cache/python-eggs
RUN mkdir -p $PYTHON_EGG_CACHE && \
    chown -R $ESGF_USER:$ESGF_GROUP $PYTHON_EGG_CACHE

# Install and configure Conda
ARG PYTHON_MAJOR_VERSION=3
ARG CONDA_VERSION=4.7.12.1
RUN curl -fsSL -o miniconda.sh https://repo.anaconda.com/miniconda/Miniconda${PYTHON_MAJOR_VERSION}-${CONDA_VERSION}-Linux-x86_64.sh && \
    /bin/bash miniconda.sh -f -b -p $CONDA_HOME && \
    rm miniconda.sh && \
    echo "conda ${CONDA_VERSION}" >> $CONDA_HOME/conda-meta/pinned && \
    conda config --system --prepend channels conda-forge && \
    conda config --system --set auto_update_conda false && \
    conda config --system --set show_channel_urls true && \
    conda install --quiet --yes conda && \
    conda update --all --quiet --yes && \
    conda list python | grep '^python ' | tr -s ' ' | cut -d '.' -f 1,2 | sed 's/$/.*/' >> $CONDA_HOME/conda-meta/pinned && \
    conda clean --all -f -y

USER $ESGF_UID
