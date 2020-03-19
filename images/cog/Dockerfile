#####
## Docker image for the ESGF SLCS Django application
#####

ARG ESGF_REPOSITORY_BASE=esgfhub
ARG ESGF_IMAGES_VERSION=latest

FROM ${ESGF_REPOSITORY_BASE}/python2:${ESGF_IMAGES_VERSION} as builder

USER root

RUN yum makecache && \
    yum install -y git gcc postgresql-devel sqlite-devel openssl-devel && \
    yum clean all

# Clone the code into /application and build wheels of the dependencies in /build/wheelhouse
ARG ESGF_COG_REPO=https://github.com/EarthSystemCoG/COG.git
ARG ESGF_COG_VERSION=v3.15.3
RUN git clone $ESGF_COG_REPO /application && \
    pushd /application && \
    git checkout $ESGF_COG_VERSION && \
    rm -rf .git && \
    popd && \
    pip wheel --requirement /application/requirements.txt --wheel-dir /build/wheelhouse && \
    pip wheel --no-deps git+https://github.com/EarthSystemCoG/django-openid-auth.git --wheel-dir /build/wheelhouse
    #  && \
    # git clone https://github.com/globusonline/transfer-api-client-python.git /globus-client && \
    # pip wheel --wheel-dir /pip-wheels /globus-client && \
    # make -C /globus-client/mkproxy


FROM ${ESGF_REPOSITORY_BASE}/django2:${ESGF_IMAGES_VERSION}

USER root

ENV COG_INSTALL_DIR /application
ENV COG_CONFIG_DIR $ESGF_HOME/cog
RUN mkdir -p $COG_CONFIG_DIR && \
    chown $ESGF_USER:$ESGF_GROUP $COG_CONFIG_DIR

# Install additional packages not in the requirements
# COPY --from=builder /globus-client/mkproxy/mkproxy /opt/conda/lib/python2.7/site-packages/globusonline/transfer/api_client/x509_proxy/
RUN pip install --no-cache-dir --no-index --find-links /build/wheelhouse django-openid-auth && \
    pip install --no-cache-dir --no-index --find-links /build/wheelhouse --requirement /application/requirements.txt

RUN yum install -y git
RUN BUST=2; pip install --force git+https://github.com/cedadev/django-flexi-settings.git@python2#egg=django_flexi_settings
# COPY init.d/* $ESGF_INIT_DIR/

USER $ESGF_UID
