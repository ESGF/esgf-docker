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
# In the same command, in order to avoid another layer, transfer ownership of
# /usr/share/logstash to the ESGF user and group
COPY logstash.repo /etc/yum.repos.d/logstash.repo

# SHA1 is disabled by default in rocky9. 
# Logstash does not have a SHA512 hash yet.
# So SHA1 needs to be enabled to install it.
RUN update-crypto-policies --set DEFAULT:SHA1
RUN dnf makecache && \
    dnf install -y logstash-7.10.0 && \
    dnf clean all && \
    chown -R $ESGF_UID:$ESGF_GID /usr/share/logstash

# Install configuration files
COPY conf/* /etc/logstash/

USER $ESGF_UID
CMD ["logstash"]
