#####
## Base image for all images that require a basic Conda installation
#####

ARG ESGF_REPOSITORY_BASE=docker.io/esgfhub
ARG ESGF_IMAGES_VERSION=latest
FROM ${ESGF_REPOSITORY_BASE}/centos7:${ESGF_IMAGES_VERSION}

# Configure environment
ENV CONDA_DIR=/opt/conda
ENV PATH=$CONDA_DIR/bin:$PATH

# Install and configure Conda
ENV CONDA_VERSION=4.7.12.1
ENV MINICONDA_FILENAME=Miniconda3-$CONDA_VERSION-Linux-x86_64.sh
RUN curl -fsSL -o /tmp/${MINICONDA_FILENAME} https://repo.anaconda.com/miniconda/${MINICONDA_FILENAME} && \
    echo "bfe34e1fa28d6d75a7ad05fd02fa5472275673d5f5621b77380898dee1be15d2 /tmp/${MINICONDA_FILENAME}" | sha256sum --check - && \
    /bin/bash /tmp/${MINICONDA_FILENAME} -f -b -p $CONDA_DIR && \
    rm /tmp/${MINICONDA_FILENAME} && \
    echo "conda ${CONDA_VERSION}" >> $CONDA_DIR/conda-meta/pinned && \
    conda config --system --prepend channels conda-forge && \
    conda config --system --set auto_update_conda false && \
    conda config --system --set show_channel_urls true && \
    conda install --quiet --yes conda && \
    conda update --all --quiet --yes && \
    conda list python | grep '^python ' | tr -s ' ' | cut -d '.' -f 1,2 | sed 's/$/.*/' >> $CONDA_DIR/conda-meta/pinned && \
    conda clean --all -f -y
