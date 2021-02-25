#####
## Base image for all images that require a basic Conda installation
#####

ARG ESGF_REPOSITORY_BASE=esgfdeploy
ARG ESGF_IMAGES_VERSION=latest
FROM ${ESGF_REPOSITORY_BASE}/base:${ESGF_IMAGES_VERSION}

USER root

# Configure environment
ENV CONDA_HOME /opt/conda
ENV PATH $CONDA_HOME/bin:$PATH
# Don't buffer stdout and stderr as it breaks realtime logging
ENV PYTHONUNBUFFERED 1

# Install and configure Conda
ENV CONDA_VERSION=py37_4.8.3
RUN curl -fsSL -o miniconda.sh https://repo.anaconda.com/miniconda/Miniconda3-$CONDA_VERSION-Linux-x86_64.sh && \
    echo "bb2e3cedd2e78a8bb6872ab3ab5b1266a90f8c7004a22d8dc2ea5effeb6a439a *miniconda.sh" | sha256sum --check - && \
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
