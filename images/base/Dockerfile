#####
## Base image for all ESGF images
##
## Currently just a fully-updated CentOS 7 with common packages installed
#####

FROM centos:7.7.1908

ENV ESGF_HOME /esg

# Upgrade all existing packages
# Updating CACHE_BUST to the current time will bust the cache and force a rebuild
RUN CACHE_BUST="202001301309" && \
    yum makecache && yum upgrade -y && yum clean all

# Install ca-certificates and openssl
RUN yum makecache && \
    yum install -y epel-release ca-certificates openssl && \
    yum clean all

# Install Tini - see https://github.com/krallin/tini/issues/8 for why
ENV TINI_VERSION v0.18.0
RUN set -eux; \
    curl -fsSL -o /bin/tini https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini && \
    chmod +x /bin/tini

# Install our entrypoint script
COPY docker-entrypoint /bin/docker-entrypoint

# Configure the entrypoint
ENTRYPOINT ["/tini", "--", "/bin/docker-entrypoint"]
