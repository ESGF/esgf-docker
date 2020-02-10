#####
## Base image for all images that require Conda
#####

ARG ESGF_REPOSITORY_BASE=docker.io/esgfhub
ARG ESGF_IMAGES_VERSION=latest
FROM ${ESGF_REPOSITORY_BASE}/base:${ESGF_IMAGES_VERSION}

# Configure environment
ENV CONDA_HOME /opt/conda
ENV PATH $CONDA_HOME/bin:$PATH
# Don't buffer stdout and stderr as it breaks realtime logging
ENV PYTHONUNBUFFERED 1

# Install and configure Conda
ENV CONDA_VERSION=4.7.12.1
RUN curl -fsSL -o miniconda.sh https://repo.anaconda.com/miniconda/Miniconda3-$CONDA_VERSION-Linux-x86_64.sh && \
    echo "bfe34e1fa28d6d75a7ad05fd02fa5472275673d5f5621b77380898dee1be15d2 *miniconda.sh" | sha256sum --check - && \
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
