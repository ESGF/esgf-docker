#####
## Docker image for proxying the ESGF services with Nginx
#####

ARG ESGF_HUB=esgfhub
ARG ESGF_PREFIX=
ARG ESGF_VERSION=latest

# This build stage is required because COPY --from=$ARG is not supported
# https://github.com/moby/moby/issues/34482
FROM ${ESGF_HUB}/${ESGF_PREFIX}configure:${ESGF_VERSION} as configuration


FROM nginx

MAINTAINER Earth System Grid Federation <esgf-devel@lists.llnl.gov>

# Modify the default configuration to:
#   * Write logs to stdout/stderr
#   * Put the pid in a subdirectory of /var/run that is writable by the root group as well as user
#   * Allow the root group to write to the cache
#   * Allow the root group to write to conf.d
RUN sed -i "/access_log/c\    access_log \/dev\/stdout main;" /etc/nginx/nginx.conf && \
    sed -i "/error_log/c error_log \/dev\/stderr warn;" /etc/nginx/nginx.conf && \
    sed -i "/nginx.pid/c pid  /var/run/nginx/nginx.pid;" /etc/nginx/nginx.conf && \
    rm -rf /etc/nginx/conf.d/default.conf && \
    mkdir -p /var/run/nginx && chmod g+w /var/run/nginx && \
    chmod -R g+w /var/cache/nginx && \
    chmod g+w /etc/nginx/conf.d

# Install authbind and configure it to allow any user in the root group to bind ports 80 and 443
# This is to allow the proxy to run as a non-root user if desired
RUN apt-get update && \
    apt-get install -y authbind && \
    rm -rf /var/lib/apt/lists/* && \
    touch /etc/authbind/byport/80  && chmod u+x,g+x,o= /etc/authbind/byport/80 && \
    touch /etc/authbind/byport/443 && chmod u+x,g+x,o= /etc/authbind/byport/443

# Insert configuration and scripts
COPY ./conf /etc/nginx/conf.d/.defaults
# We only need the bin directory from esgf-configure
COPY --from=configuration /esg/bin /esg/bin
COPY scripts/docker-entrypoint.sh /usr/local/bin/

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD ["nginx", "-g", "daemon off;"]
