# CentOS 7 replica of jboss/keycloak (https://hub.docker.com/r/jboss/keycloak/dockerfile)

ARG ESGF_REPOSITORY_BASE=esgfdeploy
ARG ESGF_IMAGES_VERSION=latest
FROM ${ESGF_REPOSITORY_BASE}/base:${ESGF_IMAGES_VERSION}

ENV KEYCLOAK_VERSION 11.0.0
ENV JDBC_POSTGRES_VERSION 42.2.5
ENV JDBC_MYSQL_VERSION 8.0.19
ENV JDBC_MARIADB_VERSION 2.5.4
ENV JDBC_MSSQL_VERSION 7.4.1.jre11

ENV LAUNCH_JBOSS_IN_BACKGROUND 1
ENV PROXY_ADDRESS_FORWARDING false
ENV JBOSS_HOME /opt/jboss/keycloak
ENV LANG en_US.UTF-8

ARG GIT_REPO
ARG GIT_BRANCH
ARG KEYCLOAK_DIST=https://downloads.jboss.org/keycloak/$KEYCLOAK_VERSION/keycloak-$KEYCLOAK_VERSION.tar.gz

USER root

# General yum upgrade and openssl install is handled in the base image
RUN yum install -y glibc-langpack-en gzip hostname java-11-openjdk-headless tar which git && yum clean all

RUN git clone https://github.com/keycloak/keycloak-containers.git --depth 1 --branch $KEYCLOAK_VERSION /usr/local/keycloak-containers
RUN mkdir -p /opt/jboss
RUN cp -r /usr/local/keycloak-containers/server/tools /opt/jboss/
RUN /opt/jboss/tools/build-keycloak.sh

# Copy init scripts and configuration
COPY init.d/* /docker-init.d/

USER $ESGF_UID

EXPOSE 8080
EXPOSE 8443

# TODO:
# Start Keycloak in the foreground
WORKDIR /opt/jboss/keycloak/bin
CMD ["-b", "0.0.0.0"]
