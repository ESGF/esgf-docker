#####
## Container image used for setup of the configuration directory
##
## This image is designed to be run locally independently of docker-compose to
## build the required configuration
##
## It is done in a Docker image to avoid placing requirements other than Docker
## on the host
#####

# Base container is the JDK, which has openssl and keytool
FROM openjdk:8-jdk

# Install docker-compose for config generation
ARG COMPOSE_VERSION=1.22.0
RUN curl -fsSL https://github.com/docker/compose/releases/download/${COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose && \
    chmod +x /usr/local/bin/docker-compose

# Copy the scripts into the container
COPY scripts/* /usr/local/bin/

# This container expects the current esgf-docker repo to be mounted at /opt/esgf-docker
RUN mkdir -p /opt/esgf-docker
WORKDIR /opt/esgf-docker

# By default, list the available commands
ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["available-commands"]
