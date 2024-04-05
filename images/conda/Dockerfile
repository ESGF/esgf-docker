#####
## Base image for all images that require a basic Conda installation
#####

ARG ESGF_REPOSITORY_BASE=esgfdeploy
ARG ESGF_IMAGES_VERSION=latest
FROM ${ESGF_REPOSITORY_BASE}/base:${ESGF_IMAGES_VERSION}

USER root

# Configure environment
ENV MAMBA_HOME /opt/conda
ENV PATH $MAMBA_HOME/bin:$PATH
# Don't buffer stdout and stderr as it breaks realtime logging
ENV PYTHONUNBUFFERED 1

# Install and configure Conda
ARG CONDA_VERSION=23.11.0
ARG MF_RELEASE=0
ARG MF_MD5SUM=ee57176f95c313b23850e0221498f8e8
ARG MF_VERSION=$CONDA_VERSION-$MF_RELEASE
ARG INSTALLER=miniconda.sh
ARG ACTIVATE_SCRIPT=/usr/local/bin/mamba_activate.sh
RUN curl -fsSL -o $INSTALLER https://github.com/conda-forge/miniforge/releases/download/$MF_VERSION/Miniforge3-$MF_VERSION-Linux-x86_64.sh && \
    echo "${MF_MD5SUM} ${INSTALLER}" | md5sum --check - && \
    /bin/bash $INSTALLER -f -b -p $MAMBA_HOME && \
    rm $INSTALLER && \
    echo "conda ${CONDA_VERSION}" >> $MAMBA_HOME/conda-meta/pinned && \
    ${MAMBA_HOME}/bin/conda shell.bash hook > $ACTIVATE_SCRIPT && \
    . $ACTIVATE_SCRIPT && \
    conda config --system --set auto_update_conda false && \
    conda config --system --set show_channel_urls true && \
    mamba update --all --quiet --yes && \
    conda list python | grep '^python ' | tr -s ' ' | cut -d '.' -f 1,2 | sed 's/$/.*/' >> $MAMBA_HOME/conda-meta/pinned && \
    conda clean --all -f -y

USER $ESGF_UID
