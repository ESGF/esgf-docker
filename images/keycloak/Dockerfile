#####
## Base image for Keycloak
#####

ARG ESGF_REPOSITORY_BASE=esgfdeploy
ARG ESGF_IMAGES_VERSION=latest

ARG KEYCLOAK_VERSION=19.0.2
ARG KEYCLOAK_DIST=https://github.com/keycloak/keycloak/releases/download/$KEYCLOAK_VERSION/keycloak-$KEYCLOAK_VERSION.tar.gz


FROM ${ESGF_REPOSITORY_BASE}/jdk:${ESGF_IMAGES_VERSION} as build-env

# Redeclare the ARGs that are required from the global scope
ARG KEYCLOAK_VERSION
ARG KEYCLOAK_DIST

ADD $KEYCLOAK_DIST /tmp/keycloak/

# The next step makes it uniform for local development and upstream built.
# If it is a local tar archive then it is unpacked, if from remote is just downloaded.
RUN (cd /tmp/keycloak && \
    tar -xvf /tmp/keycloak/keycloak-*.tar.gz && \
    rm /tmp/keycloak/keycloak-*.tar.gz) || true

RUN mv /tmp/keycloak/keycloak-* /opt/keycloak

RUN chmod -R g+rwX /opt/keycloak


FROM ${ESGF_REPOSITORY_BASE}/jre:${ESGF_IMAGES_VERSION} as builder

COPY --from=build-env --chown=$ESGF_UID:0 /opt/keycloak /opt/keycloak

# Keycloak runs as the ESGF user
USER $ESGF_UID

EXPOSE 8080
EXPOSE 8443

# Use the custom entrypoint to correctly apply settings before Keycloak is run
CMD [ \
    "/opt/keycloak/bin/kc.sh", \
    "start" \
]
