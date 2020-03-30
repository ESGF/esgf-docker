#####
## Docker image for Nginx
##
## Configuration can be either injected by child images or by mounting files.
#####

ARG ESGF_REPOSITORY_BASE=esgfhub
ARG ESGF_IMAGES_VERSION=latest
FROM ${ESGF_REPOSITORY_BASE}/base:${ESGF_IMAGES_VERSION}

USER root

RUN yum makecache && yum install -y nginx && yum clean all

# Create the run directory and fix permissions so that any user in the
# esgf group can run the container
RUN mkdir /run/nginx && \
    chown $ESGF_USER:$ESGF_GROUP /run/nginx && \
    chmod g+w /run/nginx

# Make dhparam and dummy SSL certificates
RUN mkdir -p /etc/nginx/tls/default && \
    openssl req \
      -new -nodes -x509 -days 3650 -extensions v3_ca \
      -subj "/CN=default-server" \
      -keyout /etc/nginx/tls/default/tls.key \
      -out /etc/nginx/tls/default/tls.crt && \
    openssl dhparam -dsaparam -out /etc/nginx/tls/dhparam.pem 4096

# Install a default configuration file that uses unprivileged ports
COPY nginx.conf /etc/nginx/
COPY conf.d/* /etc/nginx/conf.d/
COPY includes/* /etc/nginx/includes/

USER $ESGF_UID
CMD ["nginx", "-g", "daemon off;"]
