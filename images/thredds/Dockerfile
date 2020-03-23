#####
## Image for running THREDDS
#####

ARG ESGF_REPOSITORY_BASE=esgfhub
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

# Copy the unpacked webapp from the builder
COPY --from=builder /application ./webapps/thredds

# Make the content root directory and point tomcat at it
RUN mkdir content && chown $ESGF_USER:$ESGF_GROUP content
ENV CATALINA_EXTRA_OPTS "-Dtds.content.root.path=$CATALINA_HOME/content"

USER $ESGF_UID
