#####
## Base image for all Tomcat runtime images
#####

ARG ESGF_REPOSITORY_BASE=esgfhub
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
ARG TOMCAT_VERSION=8.5.50
ARG TOMCAT_SHA512=ffca86027d298ba107c7d01c779318c05b61ba48767cc5967ee6ce5a88271bb6ec8eed60708d45453f30eeedddcaedd1a369d6df1b49eea2cd14fa40832cfb90
ARG TOMCAT_URL=https://archive.apache.org/dist/tomcat/tomcat-$TOMCAT_MAJOR_VERSION/v$TOMCAT_VERSION/bin/apache-tomcat-$TOMCAT_VERSION.tar.gz
RUN curl -fsSL -o tomcat.tar.gz $TOMCAT_URL && \
    echo "$TOMCAT_SHA512 *tomcat.tar.gz" | sha512sum --strict --check && \
    tar -xzf tomcat.tar.gz --strip-components=1 && \
    # Cleanup tar file, remove Windows scripts and default webapps
    rm -rf tomcat.tar.gz bin/*.bat webapps/* && \
    # Fix permissions for running as tomcat
    chmod -R +rX . && \
    chown -R $ESGF_USER:$ESGF_GROUP logs temp work
# Install custom configs
COPY context.xml server.xml tomcat-users.xml conf/
COPY setenv.sh bin/

# By default, execute the Tomcat server as the tomcat user
USER $ESGF_UID
CMD ["catalina.sh", "run"]
