# Official tomcat container but running with an unprivileged user

FROM tomcat:8

MAINTAINER Earth System Grid Federation <esgf-devel@lists.llnl.gov>

ENV TOMCAT_USER tomcat
ENV TOMCAT_GROUP tomcat
ENV TOMCAT_UID 501
ENV TOMCAT_GID 501

# Remove the default webapps
# Because we don't want to use *, we have to use bash (the default shell is sh)
# and enable brace expansion for the command
# Using this form of RUN prevents the use of 'sh -c {}' to run the command
RUN ["/bin/bash", "-B", "-c", "rm -rf $CATALINA_HOME/webapps/{docs,examples,host-manager,manager}"]

# Create the tomcat user and group
RUN groupadd -g $TOMCAT_GID $TOMCAT_GROUP &&  \
    useradd -d $CATALINA_HOME -g $TOMCAT_GROUP -s /usr/sbin/nologin -u $TOMCAT_UID $TOMCAT_USER

# Transfer ownership of CATALINA_HOME to TOMCAT_USER
RUN chown -R $TOMCAT_USER:$TOMCAT_GROUP $CATALINA_HOME

# Create /esg/config and transfer ownership to tomcat
RUN mkdir -p /esg/config && chown -R $TOMCAT_USER:$TOMCAT_GROUP /esg/config

# Run any future commands as TOMCAT_USER
USER $TOMCAT_USER
