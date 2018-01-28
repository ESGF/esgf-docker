#####
## Docker image for proxying the ESGF services with Nginx
#####

FROM nginx

MAINTAINER Earth System Grid Federation <esgf-devel@lists.llnl.gov>

# Modify the default configuration
RUN sed -i "/access_log/c\    access_log \/dev\/stdout main;" /etc/nginx/nginx.conf && \
    sed -i "/error_log/c error_log \/dev\/stderr warn;" /etc/nginx/nginx.conf && \
    rm -rf /etc/nginx/conf.d/default.conf

# Insert custom configuration
# The Nginx config file contains references to environment variables that are
# processed by the custom entrypoint before Nginx is started
COPY conf/esgf.conf /etc/nginx/conf.d/
COPY scripts/docker-entrypoint.sh /usr/local/bin/

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD ["nginx", "-g", "daemon off;"]
