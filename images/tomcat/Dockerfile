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
ARG TOMCAT_MAJOR_VERSION=8
ARG TOMCAT_VERSION=8.5.81
ARG TOMCAT_SHA512=729387275cce4a0900289722f6c70ebcf7aee924af671b110b8ea8577fd6d045d47f17d526c8db5fd41c8590102e7f5100e95e89f7fd511b941565812ecbed35
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
