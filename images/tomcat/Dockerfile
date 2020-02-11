#####
## Base image for all images that require Tomcat
#####

ARG ESGF_REPOSITORY_BASE=esgfhub
ARG ESGF_IMAGES_VERSION=latest
FROM ${ESGF_REPOSITORY_BASE}/base:${ESGF_IMAGES_VERSION}

USER root

# Create Tomcat home at /opt/tomcat
ENV JAVA_HOME /usr/lib/jvm/jre
ENV CATALINA_HOME /opt/tomcat
ENV PATH $CATALINA_HOME/bin:$PATH
RUN mkdir -p $CATALINA_HOME
WORKDIR $CATALINA_HOME

# Install java
RUN yum makecache && \
    yum install -y java-1.8.0-openjdk-1.8.0.242* && \
    yum clean all

# Download and install Tomcat 8
ENV TOMCAT_MAJOR_VERSION 8
ENV TOMCAT_VERSION 8.5.50
ENV TOMCAT_SHA512 ffca86027d298ba107c7d01c779318c05b61ba48767cc5967ee6ce5a88271bb6ec8eed60708d45453f30eeedddcaedd1a369d6df1b49eea2cd14fa40832cfb90
RUN curl -fsSL -o tomcat.tar.gz https://archive.apache.org/dist/tomcat/tomcat-$TOMCAT_MAJOR_VERSION/v$TOMCAT_VERSION/bin/apache-tomcat-$TOMCAT_VERSION.tar.gz && \
    echo "$TOMCAT_SHA512 *tomcat.tar.gz" | sha512sum --strict --check && \
    tar -xzf tomcat.tar.gz --strip-components=1 && \
    # Cleanup tar file, remove Windows scripts and default webapps
    rm -rf tomcat.tar.gz bin/*.bat webapps/* && \
    # Fix permissions for running as tomcat
    chmod -R +rX . && \
    chown -R $ESG_USER:$ESG_GROUP logs temp work
# Install custom configs
COPY context.xml server.xml conf/
COPY setenv.sh bin/
COPY tomcat-users.xml $ESG_HOME/tomcat/

# By default, execute the Tomcat server as the tomcat user
USER $TOMCAT_UID
CMD ["catalina.sh", "run"]
