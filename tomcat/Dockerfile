# Official tomcat container but running with an unprivileged user

FROM tomcat:8

MAINTAINER Earth System Grid Federation <esgf-devel@lists.llnl.gov>

ENV TOMCAT_USER tomcat
ENV TOMCAT_GROUP tomcat
ENV TOMCAT_UID 501
ENV TOMCAT_GID 501

# Create the tomcat user and group
RUN groupadd -g $TOMCAT_GID $TOMCAT_GROUP &&  \
    useradd -d $CATALINA_HOME -g $TOMCAT_GROUP -s /usr/sbin/nologin -u $TOMCAT_UID $TOMCAT_USER

# Transfer ownership of CATALINA_HOME to TOMCAT_USER
RUN chown -R $TOMCAT_USER:$TOMCAT_GROUP $CATALINA_HOME

# Create /esg/config and transfer ownership to tomcat
RUN mkdir -p /esg/config && chown -R $TOMCAT_USER:$TOMCAT_GROUP /esg/config

# Run any future commands as TOMCAT_USER
USER $TOMCAT_USER
