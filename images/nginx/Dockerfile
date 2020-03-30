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

# Make the default log locations go to stdout and stderr
# Also fix some permissions so that any user in the esgf group can run the container
RUN mkdir /run/nginx && \
    chown -R $ESGF_USER:$ESGF_GROUP /var/log/nginx /var/lib/nginx /run/nginx && \
    chmod -R g+w /var/log/nginx /var/lib/nginx /run/nginx && \
    ln -sf /dev/stdout /var/log/nginx/access.log && \
    ln -sf /dev/stderr /var/log/nginx/error.log

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
