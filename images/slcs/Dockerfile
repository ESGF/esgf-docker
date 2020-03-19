#####
## Docker image for the ESGF SLCS Django application
#####

ARG ESGF_REPOSITORY_BASE=esgfhub
ARG ESGF_IMAGES_VERSION=latest

FROM ${ESGF_REPOSITORY_BASE}/python3:${ESGF_IMAGES_VERSION} as builder

USER root

RUN yum makecache && yum install -y git && yum clean all

# Clone the SLCS code into /application and build wheels of the dependencies in /build/wheelhouse
ARG ESGF_SLCS_REPO=https://github.com/ESGF/esgf-slcs-server.git
ARG ESGF_SLCS_VERSION=7397e0fc3dd51cc161148db4c3bf7f29fd708ac7
RUN git clone $ESGF_SLCS_REPO /application && \
    pushd /application && \
    git checkout $ESGF_SLCS_VERSION && \
    rm -rf .git && \
    popd && \
    pip wheel --no-deps --requirement /application/requirements.txt --wheel-dir /build/wheelhouse


FROM ${ESGF_REPOSITORY_BASE}/django3:${ESGF_IMAGES_VERSION}

# Install the app settings file
# These are settings that define the application rather than runtime settings
COPY 10-app-settings.py $DJANGO_SETTINGS_DIR/
