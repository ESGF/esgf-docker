#####
## Base image for all ESGF images
##
## Currently just a fully-updated CentOS 7 with ca-certificates + openssl
#####

FROM centos:7.7.1908

# Upgrade all existing packages
# Updating CACHE_BUST to the current time will bust the cache and force a rebuild
RUN CACHE_BUST="202001060949" && \
    yum makecache && yum upgrade -y && yum clean all

# Install ca-certificates and openssl
RUN yum makecache && \
    yum install -y ca-certificates openssl && \
    yum clean all
