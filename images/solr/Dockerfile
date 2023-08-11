#####
## Docker image for Solr with the ESGF core template installed
#####

ARG ESGF_REPOSITORY_BASE=esgfdeploy
ARG ESGF_IMAGES_VERSION=latest
FROM ${ESGF_REPOSITORY_BASE}/base:${ESGF_IMAGES_VERSION}

USER root

# Specific version of Java required by SOLR
RUN dnf makecache && \
    dnf install -y java-1.8.0-openjdk-headless-1.8.0.382.b05-2.el9.x86_64 && \
    dnf clean all

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

# Patch log4j
ARG LIB_PATH=/opt/solr/server/lib/ext
RUN rm -f $LIB_PATH/log4j-1.2.17.jar

# Install Log4j 1.x to 2.x jars
RUN export JAR=log4j-1.2-api-2.20.0.jar && \
    curl https://repo1.maven.org/maven2/org/apache/logging/log4j/log4j-1.2-api/2.20.0/$JAR --output $LIB_PATH/$JAR && \
    echo "689151374756cb809cb029f2501015bdc7733179 *$LIB_PATH/$JAR" | sha1sum --strict --check
RUN export JAR=log4j-core-2.20.0.jar && \
    curl https://repo1.maven.org/maven2/org/apache/logging/log4j/log4j-core/2.20.0/$JAR --output $LIB_PATH/$JAR && \
    echo "eb2a9a47b1396e00b5eee1264296729a70565cc0 *$LIB_PATH/$JAR" | sha1sum --strict --check
RUN export JAR=log4j-api-2.20.0.jar && \
    curl https://repo1.maven.org/maven2/org/apache/logging/log4j/log4j-api/2.20.0/$JAR --output $LIB_PATH/$JAR && \
    echo "1fe6082e660daf07c689a89c94dc0f49c26b44bb *$LIB_PATH/$JAR" | sha1sum --strict --check

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
