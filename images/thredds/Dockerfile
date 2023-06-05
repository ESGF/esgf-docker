#####
## Image for running THREDDS
#####

ARG ESGF_REPOSITORY_BASE=esgfdeploy
ARG ESGF_IMAGES_VERSION=latest

FROM ${ESGF_REPOSITORY_BASE}/jdk:${ESGF_IMAGES_VERSION} as builder

# Unpack the THREDDS war
ARG THREDDS_VERSION=5.5
ARG THREDDS_SHA1=0a5ff524938ff94e5f554d99543e9fbe3f178f2a
ARG THREDDS_URL=https://downloads.unidata.ucar.edu/tds/$THREDDS_VERSION/thredds-$THREDDS_VERSION-SNAPSHOT.war
RUN mkdir /application && \
    cd /application && \
    curl -fsSL -o thredds.war $THREDDS_URL && \
    echo "$THREDDS_SHA1 *thredds.war" | sha1sum --strict --check && \
    jar xvf thredds.war && \
    rm thredds.war


FROM ${ESGF_REPOSITORY_BASE}/tomcat:${ESGF_IMAGES_VERSION}

USER root

# Create symlinks for log files to stdout
RUN ln -s /dev/stdout ./logs/serverStartup.log && \
    ln -s /dev/stdout ./logs/catalogInit.log && \
    ln -s /dev/stdout ./logs/httpout.log && \
    ln -s /dev/stdout ./logs/featureCollectionScan.log && \
    ln -s /dev/stdout ./logs/fmrc.log && \
    ln -s /dev/stdout ./logs/threddsServlet.log && \
    ln -s /dev/stdout ./logs/cache.log
# Tell THREDDS where to put content
ENV CATALINA_EXTRA_OPTS "-Dtds.content.root.path=$CATALINA_HOME/content"

# Copy the unpacked webapp from the builder
COPY --from=builder /application ./webapps/thredds
# Install configuration files
COPY log4j2.xml ./webapps/thredds/WEB-INF/classes/
COPY threddsConfig.xml catalog.xml ./content/thredds/
COPY catalog-esgcet.xml ./content/thredds/esgcet/catalog.xml

# Run THREDDS until a successful startup to generate initial files
# This means that later we can run with a readonly root filesystem for security purposes
RUN catalina.sh start && \
    # Sleep for 5s to avoid connection refused errors (curl version is too old for --retry-connrefused)
    sleep 5 && \
    # Try to fetch the catalog every 5s for 5m before failing
    curl -fsSL -o /dev/null --retry 60 --retry-delay 5 --retry-max-time 300 http://127.0.0.1:8080/thredds/catalog/catalog.html && \
    catalina.sh stop && \
    # Remove any transient files that were created
    rm -f ./logs/catalina.{log,out} && \
    rm -rf ./temp/* ./work/* && \
    rm -rf ./content/thredds/cache/* && \
    # Transfer ownership of the entire content directory to the esgf user/group
    chown -R $ESGF_USER:$ESGF_GROUP ./content/thredds && \
    # Make the cache writable for any user in the esgf group
    chmod g+w ./content/thredds/cache

# Run as the ESGF user
USER $ESGF_UID
# Mark the THREDDS cache as a volume
# This means that permissions are preserved when a Docker named volume is mounted
VOLUME ./content/thredds/cache
