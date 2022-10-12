#####
## Image for running THREDDS
#####

ARG ESGF_REPOSITORY_BASE=esgfdeploy
ARG ESGF_IMAGES_VERSION=latest

# Make a reference to the builder
# We have to do this as a FROM because we can't use variables in COPY --from
FROM ${ESGF_REPOSITORY_BASE}/search-builder:${ESGF_IMAGES_VERSION} as builder

# Build the runtime image
FROM ${ESGF_REPOSITORY_BASE}/tomcat:${ESGF_IMAGES_VERSION}

USER root

RUN yum makecache && \
    yum remove -y java-11-openjdk-headless && \
    yum install -y java-1.8.0-openjdk-headless-1.8.0.345.b01 && \
    yum clean all

# Copy the unpacked webapp from the builder
COPY --from=builder /application ./webapps/esg-search
# Install a custom log4j.xml that doesn't roll log files
COPY log4j.xml ./webapps/esg-search/WEB-INF/classes/
# By default, send the search log to stdout
RUN ln -s /dev/stdout ./logs/esgf-search.log

USER $ESGF_UID
