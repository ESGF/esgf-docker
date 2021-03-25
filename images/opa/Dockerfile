#####
## Docker image for the OPA server
#####

ARG ESGF_REPOSITORY_BASE=esgfdeploy
ARG ESGF_IMAGES_VERSION=latest
ARG OPA_URL=https://github.com/open-policy-agent/opa/releases/download/v0.11.0/opa_linux_amd64

FROM ${ESGF_REPOSITORY_BASE}/base:${ESGF_IMAGES_VERSION}

ARG OPA_URL

USER root

RUN curl -L $OPA_URL -o /opa
RUN chown -R $ESGF_USER:$ESGF_GROUP /opa
RUN chmod +x /opa

USER $ESGF_UID

ENTRYPOINT ["/opa"]
CMD ["run"]
