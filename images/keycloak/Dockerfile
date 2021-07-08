#####
## Base image for Keycloak
#####

ARG ESGF_REPOSITORY_BASE=esgfdeploy
ARG ESGF_IMAGES_VERSION=latest

ARG KEYCLOAK_VERSION=11.0.2
ARG KEYCLOAK_DIST=https://downloads.jboss.org/keycloak/$KEYCLOAK_VERSION/keycloak-$KEYCLOAK_VERSION.tar.gz

# JDBC library enables an optional PostgreSQL database for Keycloak server deployments
ARG JDBC_POSTGRES_VERSION=42.2.5
ARG JDBC_MYSQL_VERSION=8.0.19
ARG JDBC_MARIADB_VERSION=2.5.4
ARG JDBC_MSSQL_VERSION=7.4.1.jre11


FROM ${ESGF_REPOSITORY_BASE}/base:${ESGF_IMAGES_VERSION} as keycloak-containers-source

USER root
ARG KEYCLOAK_VERSION

# Install Git and clone the keycloak container repository
RUN yum makecache && yum install -y git && yum clean all
RUN git clone --single-branch -b $KEYCLOAK_VERSION https://github.com/keycloak/keycloak-containers /source


FROM ${ESGF_REPOSITORY_BASE}/jdk:${ESGF_IMAGES_VERSION} as keycloak-build

# Redeclare the ARGs that are required from the global scope
ARG KEYCLOAK_VERSION
ARG KEYCLOAK_DIST
ARG JDBC_POSTGRES_VERSION
ARG JDBC_MYSQL_VERSION
ARG JDBC_MARIADB_VERSION
ARG JDBC_MSSQL_VERSION

# Environment variables used by the build script
ENV LAUNCH_JBOSS_IN_BACKGROUND 1
ENV PROXY_ADDRESS_FORWARDING false
ENV JBOSS_HOME /opt/jboss/keycloak
ENV LANG en_US.UTF-8

# Yum packages for the Keycloak build process
RUN yum makecache && \
    yum install -y glibc-langpack-en gzip hostname tar which && \
    yum clean all

# Copy the keycloak-containers tools directory from the named stage
COPY --from=keycloak-containers-source /source/server/tools /opt/jboss/tools

# Run the build script to install Keycloak
RUN /opt/jboss/tools/build-keycloak.sh


FROM ${ESGF_REPOSITORY_BASE}/jre:${ESGF_IMAGES_VERSION}

USER root

# Copy the Keycloak server installation from the named stage
COPY --from=keycloak-build --chown=$ESGF_UID:root /opt/jboss/keycloak /opt/jboss/keycloak
COPY --from=keycloak-build --chown=$ESGF_UID:root /opt/jboss/tools /opt/jboss/tools

# Copy configuration files for scripted installation
COPY --chown=$ESGF_UID:root configuration/* /opt/jboss/deploy/

# Cleanup installation and create required directories
RUN rm -rf /opt/jboss/keycloak/standalone/data/* && \
    rm -rf /opt/jboss/keycloak/standalone/configuration/* && \
    mkdir -p /standalone/configuration/keystores && \
    chown $ESGF_UID:root -R /standalone

# Install init scripts
COPY init.d/* /docker-init.d/

# Keycloak runs as the ESGF user
USER $ESGF_UID

EXPOSE 8080
EXPOSE 8443

# Use the custom entrypoint to correctly apply settings before Keycloak is run
CMD [ \
    "/opt/jboss/tools/docker-entrypoint.sh", \
    "-Djboss.bind.address=0.0.0.0", \
    "-Djboss.bind.address.private=127.0.0.1" \
]
