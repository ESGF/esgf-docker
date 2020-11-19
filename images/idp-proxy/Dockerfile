#####
## Docker image for the ESGF IDP Proxy Keycloak service
#####

ARG ESGF_REPOSITORY_BASE=esgfdeploy
ARG ESGF_IMAGES_VERSION=latest

ARG THEME_GIT_REPOSITORY=https://github.com/ESGF/esgf-idp-proxy-theme
ARG THEME_GIT_VERSION=0.1
ARG THEME_NAME=esgf


FROM ${ESGF_REPOSITORY_BASE}/base:${ESGF_IMAGES_VERSION} as theme-source

USER root

# Redeclare ARGs
ARG THEME_GIT_REPOSITORY
ARG THEME_GIT_VERSION

# Install Git and clone the theme repository
RUN yum makecache && yum install -y git && yum clean all
RUN git clone --single-branch -b $THEME_GIT_VERSION $THEME_GIT_REPOSITORY /source


FROM ${ESGF_REPOSITORY_BASE}/keycloak:${ESGF_IMAGES_VERSION}

# Install Keycloak theme from the theme-source stage
ARG THEME_NAME
COPY --from=theme-source /source/theme/$THEME_NAME \
        /opt/jboss/keycloak/themes/$THEME_NAME

# Setup custom realm import
COPY realm.json /opt/jboss/deploy/realm.json
ENV KEYCLOAK_IMPORT /opt/jboss/deploy/realm.json
