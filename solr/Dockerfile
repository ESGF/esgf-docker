#####
## Standard Solr container with setup of ESGF cores built-in
#####

FROM solr:5.5

MAINTAINER Earth System Grid Federation <esgf-devel@lists.llnl.gov>

# In order to consistently resolve permissions issues with volumes, we need to be root
USER root

# Install netcat so we can check if zookeeper is up
RUN apt-get update && apt-get install -y netcat && rm -rf /var/lib/apt/lists/*

# But we want to run the solr command as the solr user
# Use gosu for better sudo, as recommended here: https://docs.docker.com/engine/userguide/eng-image/dockerfile_best-practices/#user
ENV GOSU_VERSION 1.10
RUN curl -o /usr/local/bin/gosu -sSL "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-amd64" && \
    curl -o /usr/local/bin/gosu.asc -sSL "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-amd64.asc" && \
    export GNUPGHOME="$(mktemp -d)" && \
    gpg --keyserver keyserver.ubuntu.com --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 && \
    gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu && \
    rm -rf "$GNUPGHOME" /usr/local/bin/gosu.asc && \
    chmod +x /usr/local/bin/gosu && \
    gosu nobody true

# Install the ESGF configset
COPY config /esg/solr-config

# Install the Docker entrypoint script that sets up the environment and switches to solr user
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD ["solr-foreground"]
