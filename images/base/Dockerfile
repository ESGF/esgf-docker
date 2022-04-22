#####
## Base image for all ESGF images
##
## Currently just a fully-updated CentOS 7 with common packages and entrypoint
#####

FROM centos:7.8.2003

# Create the esgf user that will be used to run apps
ENV ESGF_UID 1000
ENV ESGF_GID 1000
ENV ESGF_USER esgf
ENV ESGF_GROUP esgf
RUN groupadd --gid $ESGF_GID $ESGF_GROUP && \
    useradd \
      --no-create-home \
      --no-user-group \
      --gid $ESGF_GID \
      --shell /sbin/nologin \
      --uid $ESGF_UID \
      $ESGF_USER

# Set the locale to UTF-8 for all containers
ENV LANG en_US.UTF-8
ENV LC_ALL en_US.UTF-8

# Upgrade all existing packages
# Updating CACHE_BUST to the current time will bust the cache and force a rebuild
RUN CACHE_BUST="20220421"; \
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

# Set the default user and entrypoint
USER $ESGF_UID
ENTRYPOINT ["/usr/local/bin/tini", "-g", "--", "/usr/local/bin/docker-entrypoint.sh"]
