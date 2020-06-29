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
ARG SOLR_VERSION=8.5.2
ARG SOLR_SHA512=02b9b90468f399701dba26695c9af6cd205f47916a06e26838613fe238594e9902de6ef3b42ec8257d195e37589adf8427d9b7962557731e91949fbef06bb544
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

# Copy init scripts
COPY solr.in.sh /etc/default/solr.in.sh
COPY init.d/* /docker-init.d/

USER $ESGF_UID

# Start Solr in the foreground
WORKDIR /opt/solr
VOLUME /var/solr/data
CMD ["solr", "-f"]
