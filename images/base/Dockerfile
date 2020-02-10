#####
## Base image for all ESGF images
##
## Currently just a fully-updated CentOS 7 with common packages and entrypoint
#####

FROM centos:7.7.1908

ENV ESGF_HOME /esg

# Upgrade all existing packages
# Updating CACHE_BUST to the current time will bust the cache and force a rebuild
RUN CACHE_BUST="202002101000" && \
    yum makecache && yum upgrade -y && yum clean all

# Install ca-certificates and openssl
RUN yum makecache && \
    yum install -y epel-release ca-certificates openssl && \
    yum clean all

# Install Tini
ENV TINI_VERSION v0.18.0
RUN curl -fsSL -o /usr/local/bin/tini https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini && \
    chmod +x /usr/local/bin/tini

# Include a custom entrypoint that will execute startup scripts
COPY docker-entrypoint.sh /usr/local/bin/

# Set the default entrypoint
ENTRYPOINT ["/usr/local/bin/tini", "-g", "--", "/usr/local/bin/docker-entrypoint.sh"]
