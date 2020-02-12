#####
## Base image for all tomcat builder images
##
## We build tomcat images as a two-stage process to avoid having build
## artifacts in the runtime image, and so the runtime image can have
## just the JRE instead of the full JDK
#####

ARG ESGF_REPOSITORY_BASE=esgfhub
ARG ESGF_IMAGES_VERSION=latest
FROM ${ESGF_REPOSITORY_BASE}/base:${ESGF_IMAGES_VERSION}

USER root

# Install JDK
RUN yum makecache && \
    yum install -y java-1.8.0-openjdk-devel-1.8.0.242* && \
    yum clean all

# Unpack the specified war file using ONBUILD
ONBUILD ARG WAR_LOCATION
ONBUILD RUN \
  mkdir /application && \
  cd /application && \
  curl -fsSL -o application.war $WAR_LOCATION && \
  jar xvf application.war && \
  rm application.war
