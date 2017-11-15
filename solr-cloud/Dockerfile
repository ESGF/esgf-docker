# Solr-Cloud installation configured for ESGF data

FROM $ESGF_IMAGES_HUB/esgf-node:$ESGF_VERSION
MAINTAINER Earth System Grid Federation <esgf-devel@lists.llnl.gov>

ARG ESGF_IMAGES_HUB=esgfhub
ARG ESGF_VERSION=devel

# Maven
ENV MAVEN_VERSION 3.3.9
RUN mkdir -p /usr/share/maven \
    && curl -fsSL http://mirrors.sonic.net/apache/maven/maven-3/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.tar.gz \
       | tar -xzC /usr/share/maven --strip-components=1 \
    && ln -s /usr/share/maven/bin/mvn /usr/bin/mvn
ENV MAVEN_HOME /usr/share/maven
VOLUME /root/.m2

# create installation and data directories
ENV SOLR_CLOUD_INSTALL /usr/local/solr-cloud-install
RUN mkdir -p $SOLR_CLOUD_INSTALL
ENV SOLR_CLOUD_HOME /esg/solr-cloud-home
RUN mkdir -p $SOLR_CLOUD_HOME

# mvn: install 3 Solr instances configured for ESGF
ENV SRC_DIR /usr/local/src
RUN mkdir  -p $SRC_DIR
RUN cd $SRC_DIR && \
    git clone https://github.com/ESGF/esg-search.git && \
    cd esg-search && \
    git checkout -b devel origin/devel && \
    cd etc/solr-cloud && \    
    mvn install

# Python software for harvesting/migrating Solr catalogs
# and dependencies
RUN pip install solrpy
RUN cd $SRC_DIR && \
    git clone https://github.com/EarthSystemCoG/esgfpy-publish.git

# scripts
COPY scripts/ /usr/local/bin/

EXPOSE 8983 8984 8985

# startup
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
