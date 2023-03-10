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
    yum install -y zip && \
    yum clean all

# Copy the unpacked webapp from the builder
COPY --from=builder /application ./webapps/esg-search
# Install a custom log4j.xml that doesn't roll log files
COPY log4j.xml ./webapps/esg-search/WEB-INF/classes/
# By default, send the search log to stdout
RUN ln -s /dev/stdout ./logs/esgf-search.log

ARG LIB_PATH=/opt/tomcat/webapps/esg-search/WEB-INF/lib

# Remove all log4j jars and classes
RUN rm -f $LIB_PATH/log4j-1.2.17.jar
RUN zip $LIB_PATH/esgf-node-manager-accesslog-client-1.0.5.jar -d org/apache/log4j/\*
RUN zip $LIB_PATH/esgf-node-manager-connector-1.0.5.jar -d org/apache/log4j/\*

# Install Log4j 1.x to 2.x jars
RUN export JAR=log4j-1.2-api-2.20.0.jar && \
    curl https://repo1.maven.org/maven2/org/apache/logging/log4j/log4j-1.2-api/2.20.0/$JAR --output $LIB_PATH/$JAR && \
    echo "689151374756cb809cb029f2501015bdc7733179 *$LIB_PATH/$JAR" | sha1sum --strict --check
RUN export JAR=log4j-core-2.20.0.jar && \
    curl https://repo1.maven.org/maven2/org/apache/logging/log4j/log4j-core/2.20.0/$JAR --output $LIB_PATH/$JAR && \
    echo "eb2a9a47b1396e00b5eee1264296729a70565cc0 *$LIB_PATH/$JAR" | sha1sum --strict --check
RUN export JAR=log4j-api-2.20.0.jar && \
    curl https://repo1.maven.org/maven2/org/apache/logging/log4j/log4j-api/2.20.0/$JAR --output $LIB_PATH/$JAR && \
    echo "1fe6082e660daf07c689a89c94dc0f49c26b44bb *$LIB_PATH/$JAR" | sha1sum --strict --check

USER $ESGF_UID
