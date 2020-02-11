#####
## Base image for all ESGF images
##
## Currently just a fully-updated CentOS 7 with common packages and entrypoint
#####

FROM centos:7.7.1908

# Create the /esg directory
ENV ESG_HOME /esg
ENV ESG_CONFIG_DIR $ESG_HOME/config
ENV ESG_CERT_DIR $ESG_HOME/certificates
ENV ESG_INIT_DIR $ESG_HOME/init.d
RUN mkdir -p $ESG_CONFIG_DIR && mkdir -p $ESG_CERT_DIR && mkdir -p $ESG_INIT_DIR

# Create the esg user that will be used to run apps
ENV ESG_UID 1000
ENV ESG_GID 1000
ENV ESG_USER esg
ENV ESG_GROUP esg
RUN groupadd --gid $ESG_GID $ESG_GROUP && \
    useradd \
      --no-create-home \
      --no-user-group \
      --gid $ESG_GID \
      --shell /sbin/nologin \
      --uid $ESG_UID \
      $ESG_USER

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
# This init script adds the certificates from $ESG_CERT_DIR to the system trust roots
# It is numbered 00 so that it runs first
COPY 00-esg-update-trust.sh $ESG_INIT_DIR/
# Allow users in the esg group to update the trust roots
RUN chown $ESG_USER:$ESG_GROUP /etc/pki/ca-trust/source/anchors && \
    chown -R $ESG_USER:$ESG_GROUP /etc/pki/ca-trust/extracted && \
    chmod g+w /etc/pki/ca-trust/source/anchors && \
    chmod -R g+w /etc/pki/ca-trust/extracted

# Set the default user and entrypoint
USER $ESG_UID
ENTRYPOINT ["/usr/local/bin/tini", "-g", "--", "/usr/local/bin/docker-entrypoint.sh"]
