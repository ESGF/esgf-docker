#####
## Base image for all Tomcat runtime images
#####

ARG ESGF_REPOSITORY_BASE=esgfdeploy
ARG ESGF_IMAGES_VERSION=latest
FROM ${ESGF_REPOSITORY_BASE}/jre:${ESGF_IMAGES_VERSION}

USER root

# Create Tomcat home at /opt/tomcat
ENV JAVA_HOME /usr/lib/jvm/jre
ENV CATALINA_HOME /opt/tomcat
ENV PATH $CATALINA_HOME/bin:$PATH
RUN mkdir -p $CATALINA_HOME
WORKDIR $CATALINA_HOME

# Download and install Tomcat 8
ARG TOMCAT_MAJOR_VERSION=9
ARG TOMCAT_VERSION=9.0.94
ARG TOMCAT_SHA512=14d941808565bac5913b94d3ad24e1d783ab1dfb29b7aee32b9ce1b5c7629a3a836b944b8ee7990d1719e75cf8cc928efdf682cdd4b908eaa77c69cd37e9f436
ARG TOMCAT_URL=https://archive.apache.org/dist/tomcat/tomcat-$TOMCAT_MAJOR_VERSION/v$TOMCAT_VERSION/bin/apache-tomcat-$TOMCAT_VERSION.tar.gz
RUN curl -fsSL -o tomcat.tar.gz $TOMCAT_URL && \
    echo "$TOMCAT_SHA512 *tomcat.tar.gz" | sha512sum --strict --check && \
    tar -xzf tomcat.tar.gz --strip-components=1 && \
    # Cleanup tar file, remove Windows scripts and default webapps
    rm -rf tomcat.tar.gz bin/*.bat webapps/* && \
    # Fix permissions - we want any user in the tomcat group to be able to run the container
    chmod -R +rX . && \
    chown -R $ESGF_USER:$ESGF_GROUP logs temp work && \
    chmod -R u+w,g+w logs temp work && \
    # Send tomcat logs to stdout by default
    ln -s /dev/stdout ./logs/localhost.log && \
    ln -s /dev/stdout ./logs/localhost_access_log.txt
# Install custom configs
COPY context.xml logging.properties server.xml tomcat-users.xml conf/
COPY setenv.sh bin/

# By default, execute the Tomcat server as the tomcat user
USER $ESGF_UID
CMD ["catalina.sh", "run"]
