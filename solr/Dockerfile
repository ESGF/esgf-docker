# ESGF node with Solr engine configured to serve ESGF shards

FROM esgfhub/esgf-node:1.0

MAINTAINER Luca Cinquini <luca.cinquini@jpl.nasa.gov>

# Solr/Jetty web application
ENV SOLR_VERSION 5.5.3
ENV SOLR_INSTALL_DIR /usr/local/solr
ENV SOLR_HOME /usr/local/solr-home
ENV SOLR_DATA_DIR /esg/solr-index

RUN wget -O /tmp/solr-${SOLR_VERSION}.tgz http://archive.apache.org/dist/lucene/solr/${SOLR_VERSION}/solr-${SOLR_VERSION}.tgz
RUN cd /usr/local && \
    tar xzf /tmp/solr-${SOLR_VERSION}.tgz && \
    rm /tmp/solr-${SOLR_VERSION}.tgz && \
    ln -s ./solr-${SOLR_VERSION} ./solr
RUN mkdir -p $SOLR_DATA_DIR
RUN cd /usr/local/src && \
    wget -O solr-home.tar http://distrib-coffee.ipsl.jussieu.fr/pub/esgf/dist/esg-search/solr-home.tar && \
    tar xvf /usr/local/src/solr-home.tar
RUN mkdir -p $SOLR_HOME

# add shards
COPY scripts/add_shard.sh /usr/local/bin/add_shard.sh
RUN /usr/local/bin/add_shard.sh master 8984
RUN /usr/local/bin/add_shard.sh slave 8983

EXPOSE 8983
EXPOSE 8984

COPY scripts/docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
