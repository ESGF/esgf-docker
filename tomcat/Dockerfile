# Official tomcat container but running with an unprivileged user

FROM tomcat:8

MAINTAINER Earth System Grid Federation <esgf-devel@lists.llnl.gov>

# Create the tomcat user and group
ENV TOMCAT_USER tomcat
ENV TOMCAT_GROUP tomcat
ENV TOMCAT_UID 501
ENV TOMCAT_GID 501
RUN groupadd -g $TOMCAT_GID $TOMCAT_GROUP &&  \
    useradd -d $CATALINA_HOME -g $TOMCAT_GROUP -s /usr/sbin/nologin -u $TOMCAT_UID $TOMCAT_USER

# Install gettext-base (for envsubst)
RUN apt-get update && \
    apt-get install -y gettext-base && \
    rm -rf /var/lib/apt/lists/*

# We want to start containers as root in order to deal with permissions issues
# on mounted volumes, but we want to run tomcat as an unprivileged user
# Use gosu for better sudo, as recommended here: https://docs.docker.com/engine/userguide/eng-image/dockerfile_best-practices/#user
ENV GOSU_VERSION 1.10
RUN curl -o /usr/local/bin/gosu -sSL "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-amd64" && \
    curl -o /usr/local/bin/gosu.asc -sSL "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-amd64.asc" && \
    export GNUPGHOME="$(mktemp -d)" && \
    gpg --keyserver keyserver.ubuntu.com --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 && \
    gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu && \
    rm -rf "$GNUPGHOME" /usr/local/bin/gosu.asc && \
    chmod +x /usr/local/bin/gosu && \
    gosu nobody true

# Remove the default webapps
RUN rm -rf $CATALINA_HOME/webapps/*

# Transfer ownership of CATALINA_HOME to TOMCAT_USER
RUN chown -R $TOMCAT_USER:$TOMCAT_GROUP $CATALINA_HOME

# Install custom entrypoint script
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD ["catalina.sh", "run"]
