#####
## Container image used for setup of the configuration directory
##
## This image is designed to be run locally independently of docker-compose to
## build the required configuration
##
## It is done in a Docker image to avoid placing requirements other than Docker
## on the host
#####

# Base container is the JDK, which has openssl and keytool
FROM openjdk:8-jdk

# Copy the scripts in and add them to the path
COPY scripts /opt/esgf-docker/setup-scripts
ENV PATH /opt/esgf-docker/setup-scripts:$PATH

# By default, run the full setup
ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["available-commands"]
