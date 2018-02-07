FROM centos:6

MAINTAINER Earth System Grid Federation <esgf-devel@lists.llnl.gov>

# install GPG keys
RUN rpm --import http://download.fedoraproject.org/pub/epel/RPM-GPG-KEY-EPEL-6
RUN rpm --import http://vault.centos.org/RPM-GPG-KEY-CentOS-6
RUN yum history new # That fix the warning 'Warning: RPMDB altered outside of yum'

# Install packages
RUN yum -y install epel-release # install additional epel repository

# Update yum
RUN yum -y update
RUN yum clean all

### ARGS

ARG ESGF_REPO='http://distrib-coffee.ipsl.jussieu.fr/pub/esgf'

### Common ESGF environment variables
ENV ESGF_HOME='/esg'
ENV ESGF_REPO=$ESGF_REPO
ENV ESGF_BACKUP_DIR="$ESGF_HOME/backups"
ENV ESGF_LOG_DIR="$ESGF_HOME/log"
ENV ESGF_TOOL_DIR="$ESGF_HOME/tools"
ENV ESGF_CONFIG_DIR="$ESGF_HOME/config"
ENV ESGF_CONTENT_DIR="$ESGF_HOME/content"
ENV ESGF_DEFAULT_TEST_DATA_DIR="$ESGF_HOME/data/test"

# common ESGF directories
RUN mkdir -p "$ESGF_LOG_DIR"
RUN mkdir -p "$ESGF_TOOL_DIR"
RUN mkdir -p "$ESGF_CONFIG_DIR"
RUN mkdir -p "$ESGF_BACKUP_DIR"
RUN mkdir -p "$ESGF_CONTENT_DIR"