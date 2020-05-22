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
ARG TOMCAT_VERSION=8.5.55
ARG TOMCAT_SHA512=996b653b4f81b40ae3620d6424593d23687e5ceb5cbd7357fc8d0e4b92f76903fe7fb20bf7316505e4e86269153fbfe62394bf45e59b4fb1cbc1bc95fad9eb7a
ARG TOMCAT_URL=https://archive.apache.org/dist/tomcat/tomcat-$TOMCAT_MAJOR_VERSION/v$TOMCAT_VERSION/bin/apache-tomcat-$TOMCAT_VERSION.tar.gz
RUN curl -fsSL -o tomcat.tar.gz $TOMCAT_URL && \
    echo "$TOMCAT_SHA512 *tomcat.tar.gz" | sha512sum --strict --check && \
    tar -xzf tomcat.tar.gz --strip-components=1 && \
    # Cleanup tar file, remove Windows scripts and default webapps
    rm -rf tomcat.tar.gz bin/*.bat webapps/* && \
    # Fix permissions - we want any user in the tomcat group to be able to run the container
    chmod -R +rX . && \
    chown -R $ESGF_USER:$ESGF_GROUP logs temp work && \
    chmod -R u+w,g+w logs temp work
# Install custom configs
COPY context.xml server.xml tomcat-users.xml conf/
COPY setenv.sh bin/

# By default, execute the Tomcat server as the tomcat user
USER $ESGF_UID
CMD ["catalina.sh", "run"]
