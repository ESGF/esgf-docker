#####
## Docker image for Solr with the ESGF core template installed
#####

ARG ESGF_REPOSITORY_BASE=esgfdeploy
ARG ESGF_IMAGES_VERSION=latest
FROM ${ESGF_REPOSITORY_BASE}/jre:${ESGF_IMAGES_VERSION}

USER root

# Create Solr home directory
ENV SOLR_HOME="/var/solr/data" \
    SOLR_LOGS_DIR="/var/solr/logs" \
    SOLR_INCLUDE="/etc/default/solr.in.sh" \
    PATH="/opt/solr/bin:$PATH"

# Install Solr
ARG SOLR_VERSION=7.7.3
ARG SOLR_SHA512=ca9200c18cc19ab723fd4d10f257e27eb81dc8bc33401ebc4eb99178faf4033a2684f0f8b12ae7b659cfeb0f4c9d9e24aaac518a4e00fd28b69854a359a666ed
ARG SOLR_URL=http://archive.apache.org/dist/lucene/solr/${SOLR_VERSION}/solr-${SOLR_VERSION}.tgz
RUN mkdir -p /opt/solr && \
    curl -fsSL -o /opt/solr/solr.tar.gz $SOLR_URL && \
    echo "$SOLR_SHA512 /opt/solr/solr.tar.gz" | sha512sum --strict --check && \
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

# Start Solr in the foreground
WORKDIR /opt/solr
CMD ["solr", "-f"]
