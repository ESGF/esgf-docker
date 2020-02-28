#####
## Docker image for running schema migrations
##
## Can be used as an init container for Kubernetes deployments
#####

ARG ESGF_REPOSITORY_BASE=esgfhub
ARG ESGF_IMAGES_VERSION=latest
FROM ${ESGF_REPOSITORY_BASE}/conda:${ESGF_IMAGES_VERSION} as python27

USER root

# Downgrade the conda installation to Python 2.7
RUN conda install "python<3" && \
    conda clean --all -f -y


FROM python27 as builder

# Install dependencies required to build wheels
RUN yum makecache && \
    yum install -y gcc postgresql-devel && \
    yum clean all

# Build wheels for the esgf-security dependencies
RUN mkdir -p /build/wheelhouse && \
    pip wheel --no-cache-dir --wheel-dir /build/wheelhouse \
      "psycopg2>=2.0,<2.7" \
      "SQLAlchemy>=0.5.3,<1.3" \
      "sqlalchemy_migrate>=0.6,<=0.12"


FROM python27

# Install runtime dependencies
RUN yum makecache && yum install -y postgresql && yum clean all

# Copy the wheels from the builder and install them along with the egg
ARG ESGF_SECURITY_ASSETS=https://github.com/ESGF/esgf-security/releases/download/
ARG ESGF_SECURITY_VERSION=v2.8.11
ARG ESGF_SECURITY_DB_VERSION=0.1.7
ARG ESGF_SECURITY_DB_EGG_FILENAME=esgf_security-$ESGF_SECURITY_DB_VERSION-py2.7.egg
ARG ESGF_SECURITY_DB_EGG_URL=$ESGF_SECURITY_ASSETS/$ESGF_SECURITY_VERSION/$ESGF_SECURITY_DB_EGG_FILENAME
COPY --from=builder /build/wheelhouse /build/wheelhouse
RUN pushd /build && \
    pip install --no-deps ./wheelhouse/*.whl && \
    curl -fsSLOJ $ESGF_SECURITY_DB_EGG_URL && \
    easy_install --no-deps $ESGF_SECURITY_DB_EGG_FILENAME && \
    popd

USER $ESGF_UID
