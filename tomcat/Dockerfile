# Official tomcat container but running with an unprivileged user

FROM tomcat:8

MAINTAINER Earth System Grid Federation <esgf-devel@lists.llnl.gov>

# Create the tomcat user and group
ENV TOMCAT_USER tomcat
ENV TOMCAT_GROUP tomcat
ENV TOMCAT_UID 1001
ENV TOMCAT_GID 1001
RUN groupadd -g $TOMCAT_GID $TOMCAT_GROUP &&  \
    useradd -d $CATALINA_HOME -g $TOMCAT_GROUP -s /usr/sbin/nologin -u $TOMCAT_UID $TOMCAT_USER

# Install gettext-base (for envsubst)
RUN apt-get update && \
    apt-get install -y gettext-base && \
    rm -rf /var/lib/apt/lists/*

# Allow the tomcat user and any user in the root group to add trusted CAs
RUN chown $TOMCAT_UID:0 $JAVA_HOME/lib/security/cacerts && \
    chmod u+rw,g+rw $JAVA_HOME/lib/security/cacerts

# Remove the default webapps
RUN rm -rf $CATALINA_HOME/webapps/*

# Install custom server.xml with remote IP valve
COPY conf/server.xml $CATALINA_HOME/conf/

# We want to allow running as any user in the root group
# So transfer ownership of CATALINA_HOME to the tomcat user and root group, with
# rw for both
# Remove the setgid bit from the conf directory as it prevents the root group using it
RUN chown -R $TOMCAT_UID:0 $CATALINA_HOME && \
    chmod g-s+x $CATALINA_HOME/conf && \
    chmod -R u+rw,g+rw,o= $CATALINA_HOME

# Install custom entrypoint script
COPY scripts/docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD ["catalina.sh", "run"]
