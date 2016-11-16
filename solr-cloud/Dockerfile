# Solr-Cloud installation configured for ESGF data

FROM esgfhub/esgf-node

MAINTAINER Luca Cinquini <luca.cinquini@jpl.nasa.gov>

# Maven
ENV MAVEN_VERSION 3.3.9
RUN mkdir -p /usr/share/maven \
    && curl -fsSL http://mirrors.sonic.net/apache/maven/maven-3/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.tar.gz \
       | tar -xzC /usr/share/maven --strip-components=1 \
    && ln -s /usr/share/maven/bin/mvn /usr/bin/mvn
ENV MAVEN_HOME /usr/share/maven
VOLUME /root/.m2

# create installation directory
ENV SOLR_CLOUD_HOME /usr/local/solr-cloud
RUN mkdir -p $SOLR_CLOUD_HOME

# mvn: Solr installation + ESGF configuration
ENV SRC_DIR /usr/local/src
RUN mkdir -p $SRC_DIR
RUN cd $SRC_DIR && \
    git clone https://github.com/ESGF/esg-search.git && \
    cd esg-search && \
    git checkout -b devel origin/devel && \
    cd etc/solr-cloud && \    
    mvn install

# start/stop scripts
RUN cp $SRC_DIR/esg-search/etc/solr-cloud/scripts/* /usr/local/bin/.

# Python software for harvesting/migrating Solr catalogs
# and dependencies
RUN pip install solrpy
RUN cd $SRC_DIR && \
    git clone https://github.com/EarthSystemCoG/esgfpy-publish.git

EXPOSE 8983 8984 8985
