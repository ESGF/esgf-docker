#####
## Image containing logstash
##
## It is used to send usage logs to the log aggregator operated by CMCC
#####

ARG ESGF_REPOSITORY_BASE=esgfdeploy
ARG ESGF_IMAGES_VERSION=latest
FROM ${ESGF_REPOSITORY_BASE}/base:${ESGF_IMAGES_VERSION}

USER root

# Add the logstash bin directory to the path
ENV PATH $PATH:/usr/share/logstash/bin
ENV LS_HOME /usr/share/logstash
ENV LS_SETTINGS_DIR /etc/logstash

# Use Elastic's RPM repository to install logstash
COPY logstash.repo /etc/yum.repos.d/logstash.repo
RUN yum makecache && \
    yum install -y logstash-7.10.0 && \
    yum clean all

# Install configuration files
COPY conf/* /etc/logstash/

USER $ESGF_UID
CMD ["logstash"]
