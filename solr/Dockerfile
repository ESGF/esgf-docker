#####
## Standard Solr container with setup of ESGF cores built-in
#####

FROM solr:5.5

MAINTAINER Earth System Grid Federation <esgf-devel@lists.llnl.gov>

# We need to be root to make our modifications
USER root

# Make sure solr home initialises correctly
ENV INIT_SOLR_HOME="yes"

# Install the Solr home template from the distribution site
ARG ESGF_REPO=http://dist.ceda.ac.uk/esgf
RUN mkdir -p /esg/solr-core-config && \
    curl -fsSL $ESGF_REPO/dist/esg-search/solr-home.tar | \
      tar -x -C /esg/solr-core-config --strip-components=2 solr-home/mycore && \
    rm -rf /esg/solr-core-config/core.properties && \
    sed -i \
      "s/http:\/\/localhost:8984/\${esgf.solr.master.url}/g" \
      /esg/solr-core-config/conf/solrconfig.xml

# Correct the permissions on /opt/solr so that any user in the root group can use it
RUN chown -R 8983:0 /opt/solr && chmod -R g+w /opt/solr

# Create /esg/solr-home with the correct permissions
RUN mkdir -p /esg/solr-home && chown 8983:0 /esg/solr-home && chmod 775 /esg/solr-home
VOLUME /esg/solr-home

# Install the initialisation scripts
COPY initdb.d/* /docker-entrypoint-initdb.d/

# Revert to the solr user
USER 8983
