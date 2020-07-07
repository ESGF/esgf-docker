#####
## Image for running THREDDS
#####

ARG ESGF_REPOSITORY_BASE=esgfdeploy
ARG ESGF_IMAGES_VERSION=latest

FROM ${ESGF_REPOSITORY_BASE}/jdk:${ESGF_IMAGES_VERSION} as builder

# Unpack the THREDDS war
ARG THREDDS_VERSION=5.0.0-beta7
ARG THREDDS_SHA1=32e4791ba6696eb50c5ef15259405361d32fac70
ARG THREDDS_URL=http://artifacts.unidata.ucar.edu/content/repositories/unidata-releases/edu/ucar/tds/$THREDDS_VERSION/tds-$THREDDS_VERSION.war
RUN mkdir /application && \
    cd /application && \
    curl -fsSL -o thredds.war $THREDDS_URL && \
    echo "$THREDDS_SHA1 *thredds.war" | sha1sum --strict --check && \
    jar xvf thredds.war && \
    rm thredds.war


FROM ${ESGF_REPOSITORY_BASE}/tomcat:${ESGF_IMAGES_VERSION}

USER root

# Make the content root directory, fix permissions so that any user in the
# esgf group can use it and point tomcat at it
#
# Make the cache directory with correct permissions and declare it as a volume
# This ensures that Docker named volumes will work correctly
#
# Create symlinks for log files to stdout
RUN mkdir -p ./content/thredds/{cache,logs,public} && \
    chown -R $ESGF_USER:$ESGF_GROUP ./content/thredds && \
    chmod -R u+w,g+w,o= ./content/thredds && \
    ln -s /dev/stdout ./logs/serverStartup.log && \
    ln -s /dev/stdout ./logs/catalogInit.log && \
    ln -s /dev/stdout ./logs/httpout.log && \
    ln -s /dev/stdout ./logs/featureCollectionScan.log && \
    ln -s /dev/stdout ./logs/fmrc.log && \
    ln -s /dev/stdout ./logs/threddsServlet.log && \
    ln -s /dev/stdout ./logs/cache.log
ENV CATALINA_EXTRA_OPTS "-Dtds.content.root.path=$CATALINA_HOME/content"
VOLUME ./content/thredds/cache

# Copy the unpacked webapp from the builder
COPY --from=builder /application ./webapps/thredds
# Install configuration files
COPY log4j2.xml ./webapps/thredds/WEB-INF/classes/
COPY threddsConfig.xml catalog.xml ./content/thredds/
COPY catalog-esgcet.xml ./content/thredds/esgcet/catalog.xml
# Copy the default wmsConfig.xml into place
RUN cp ./webapps/thredds/WEB-INF/altContent/startup/wmsConfig.xml ./content/thredds

USER $ESGF_UID
