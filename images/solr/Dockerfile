#####
## Docker image for Solr with the ESGF core template installed
#####

ARG ESGF_REPOSITORY_BASE=esgfdeploy
ARG ESGF_IMAGES_VERSION=latest
FROM ${ESGF_REPOSITORY_BASE}/base:${ESGF_IMAGES_VERSION}

USER root

# Specific version of Java required by SOLR
RUN yum makecache && \
    yum install -y java-1.8.0-openjdk-headless-1.8.0.345.b01 && \
    yum clean all

# Create Solr home directory
ENV SOLR_HOME="/var/solr/data" \
    SOLR_LOGS_DIR="/var/solr/logs" \
    SOLR_INCLUDE="/etc/default/solr.in.sh" \
    PATH="/opt/solr/bin:$PATH"

# Install Solr
ARG SOLR_VERSION=6.6.6
ARG SOLR_SHA1=1dfd3de06c8e6554c42e69f49573b563125da5a1
ARG SOLR_URL=http://archive.apache.org/dist/lucene/solr/${SOLR_VERSION}/solr-${SOLR_VERSION}.tgz
RUN mkdir -p /opt/solr && \
    curl -fsSL -o /opt/solr/solr.tar.gz $SOLR_URL && \
    echo "$SOLR_SHA1 /opt/solr/solr.tar.gz" | sha1sum --strict --check && \
    tar -xzf /opt/solr/solr.tar.gz -C /opt/solr --strip-components=1 && \
    rm -rf /opt/solr/solr.tar.gz && \
    rm -Rf /opt/solr/docs/ /opt/solr/dist/{solr-core-$SOLR_VERSION.jar,solr-solrj-$SOLR_VERSION.jar,solrj-lib,solr-test-framework-$SOLR_VERSION.jar,test-framework} && \
    mv /opt/solr/bin/solr.in.sh /opt/solr/bin/solr.in.sh.orig && \
    mkdir -p $SOLR_LOGS_DIR $SOLR_HOME && \
    chown $ESGF_UID:$ESGF_GID $SOLR_LOGS_DIR $SOLR_HOME && \
    chmod 0770 $SOLR_LOGS_DIR $SOLR_HOME

# Copy init scripts and configuration
COPY solr.in.sh /etc/default/solr.in.sh
COPY core-template/ /esg/core-template
COPY init.d/* /docker-init.d/

USER $ESGF_UID

# Mark Solr home as a volume
# This means that permissions are preserved when a Docker named volume is mounted
VOLUME /var/solr/data

# Start Solr in the foreground
WORKDIR /opt/solr
CMD ["solr", "-f"]
