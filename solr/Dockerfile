#####
## Standard Solr container with setup of ESGF cores built-in
#####

FROM solr:6.6

MAINTAINER Earth System Grid Federation <esgf-devel@lists.llnl.gov>

# We need to be root to make our modifications
USER root

# Make sure solr home initialises correctly
ENV INIT_SOLR_HOME "yes"
ENV SOLR_HOME /esg/solr-home

# Install the Solr home template from the distribution site
# Make customisations to the solrconfig.xml to enable extra Java properties
ARG ESG_SEARCH_VERSION=v4.17.9
ARG ESG_SEARCH_REPO=https://github.com/ESGF/esg-search/releases/download/$ESG_SEARCH_VERSION

RUN mkdir -p /esg/solr-core-config && \
    curl -fsSL $ESG_SEARCH_REPO/solr-home.tar | \
      tar -x -C /esg/solr-core-config --strip-components=2 solr-home/mycore && \
    rm -rf /esg/solr-core-config/core.properties && \
    sed -i \
      "s/http:\/\/localhost:8984\/solr/\${esgf.solr.master.url:}/g" \
      /esg/solr-core-config/conf/solrconfig.xml && \
    sed -i \
      "s/00:00:60/\${esgf.solr.replication.interval:}/g" \
      /esg/solr-core-config/conf/solrconfig.xml

# Correct the permissions on /opt/solr so that any user in the root group can use it
RUN chown -R 8983:0 /opt/solr && chmod -R g+w /opt/solr

# Create /esg/solr-home with the correct permissions
RUN mkdir -p $SOLR_HOME && chown 8983:0 $SOLR_HOME && chmod 775 $SOLR_HOME

# Install the initialisation scripts
COPY initdb.d/* /docker-entrypoint-initdb.d/

# Revert to the solr user
USER 8983
