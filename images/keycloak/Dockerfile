#####
## Base image for Keycloak
#####

ARG ESGF_REPOSITORY_BASE=esgfdeploy
ARG ESGF_IMAGES_VERSION=latest

ARG KEYCLOAK_VERSION=19.0.3
ARG KEYCLOAK_SHA1=d438c185177d3bacf5b20580d3506c4971283d3d
ARG KEYCLOAK_DIST=https://github.com/keycloak/keycloak/releases/download/$KEYCLOAK_VERSION/keycloak-$KEYCLOAK_VERSION.tar.gz


FROM ${ESGF_REPOSITORY_BASE}/jdk:${ESGF_IMAGES_VERSION} as build-env

# Redeclare the ARGs that are required from the global scope
ARG KEYCLOAK_VERSION
ARG KEYCLOAK_SHA1
ARG KEYCLOAK_DIST

ADD $KEYCLOAK_DIST /tmp/keycloak/

RUN (cd /tmp/keycloak && \
    echo "$KEYCLOAK_SHA1 *keycloak-$KEYCLOAK_VERSION.tar.gz" | sha1sum --strict --check && \
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
