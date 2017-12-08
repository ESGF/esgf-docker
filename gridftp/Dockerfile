################################# SETTING ######################################

### BASE IMAGE

ARG ESGF_IMAGES_HUB=esgfhub
ARG ESGF_VERSION=devel

FROM $ESGF_IMAGES_HUB/esgf-minimal-node:$ESGF_VERSION

MAINTAINER Earth System Grid Federation <esgf-devel@lists.llnl.gov>

### ARGS

ARG ESGF_REPO='http://distrib-coffee.ipsl.jussieu.fr/pub/esgf'

### ENVS

ENV USAGE_PARSER_VERSION='0.1.1'
ENV ESGF_GRIDFTP_JAIL_DIR="$ESGF_HOME/gridftp_root"
ENV ESGF_GRIDFTP_CONFIG_DIR="$ESGF_CONFIG_DIR/gridftp"
ENV GLOBUS_ACCOUNT='globus'

# Create the account globus (no login).
RUN groupadd "$GLOBUS_ACCOUNT"
RUN useradd -g "$GLOBUS_ACCOUNT" -m -s /bin/bash "$GLOBUS_ACCOUNT"

############################### INSTALLATION ###################################

### OS packages
RUN yum install -y wget perl-DBD-Pg tar xz

RUN wget -qO globus-connect-server-repo-latest.noarch.rpm http://toolkit.globus.org/ftppub/globus-connect-server/globus-connect-server-repo-latest.noarch.rpm
RUN rpm --import http://www.globus.org/ftppub/globus-connect-server/RPM-GPG-KEY-Globus
RUN rpm -i globus-connect-server-repo-latest.noarch.rpm
RUN rm -f globus-connect-server-repo-latest.noarch.rpm
# That fix the warning 'Warning: RPMDB altered outside of yum'
RUN yum history new
RUN yum -y install udt.x86_64 globus-connect-server-io
RUN yum -y update globus-connect-server-io

### Create /etc/yum.repos.d/esgf.repo needed to intall globus-* packages
# Generate this file as the repo can be override.
RUN echo '[esgf]' > /etc/yum.repos.d/esgf.repo
RUN echo 'name=ESGF' >> /etc/yum.repos.d/esgf.repo
RUN echo "baseurl=$ESGF_REPO/RPM/centos/6/x86_64" >> /etc/yum.repos.d/esgf.repo
RUN echo 'failovermethod=priority' >> /etc/yum.repos.d/esgf.repo
RUN echo 'enabled=1' >> /etc/yum.repos.d/esgf.repo
RUN echo 'priority=90' >> /etc/yum.repos.d/esgf.repo
RUN echo 'gpgcheck=0' >> /etc/yum.repos.d/esgf.repo
RUN echo 'proxy=_none_' >> /etc/yum.repos.d/esgf.repo

RUN yum -y install globus-authz-esgsaml-callout globus-gaa globus-adq customgsiauthzinterface
RUN yum -y update globus-authz-esgsaml-callout globus-gaa globus-adq customgsiauthzinterface

################################ CONFIGURATION #################################

# Should reveice the hostkey.pem and hostcert.pem files
RUN mkdir -p /etc/grid-security

### Configuration of Globus online platform (gridftp download via web interface)
# Skipped for now: too much user interactions

### Substitution of GCS configuration files for GridFTP server
RUN mkdir -p /etc/gridftp.d
COPY conf/globus-connect-esgf /etc/gridftp.d/

### Setup GridFTP metrics logging

RUN wget -qO- "$ESGF_REPO/dist/globus/gridftp/esg_usage_parser-$USAGE_PARSER_VERSION.tar.bz2" | tar xvj -C "/tmp"
RUN mv /tmp/esg_usage_parser "$ESGF_TOOL_DIR"
RUN chmod 755 "$ESGF_TOOL_DIR/esg_usage_parser"

# XXX static configuration esgf-node.jpl.nasa.gov as an authorization service !!!
COPY conf/esgsaml_auth.conf /etc/grid-security/

RUN grid-mapfile-add-entry -dn '^.*$' -ln "$GLOBUS_ACCOUNT"

COPY conf/globus-esgf /etc/gridftp.d

RUN mkdir -p $ESGF_GRIDFTP_CONFIG_DIR
COPY conf/esg-server-usage-gridftp.conf $ESGF_GRIDFTP_CONFIG_DIR

RUN mkdir -p $ESGF_GRIDFTP_JAIL_DIR


#??? so as to run the container with the id: globus
RUN chown -R "$GLOBUS_ACCOUNT":"$GLOBUS_ACCOUNT" /etc/gridftp.d/
RUN chown -R "$GLOBUS_ACCOUNT":"$GLOBUS_ACCOUNT" /etc/grid-security

# Post installation instructions
RUN yum erase -y wget
RUN yum clean all
