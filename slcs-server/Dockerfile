
from centos:6

MAINTAINER Frank Greguska <greguska@jpl.nasa.gov>

RUN yum clean all && \
    yum -y update && \
    yum -y install wget \
    git \
    sudo \
    epel-release \
    gcc \
    https://centos6.iuscommunity.org/ius-release.rpm
    
RUN yum -y install libffi-devel \
    openssl-devel \
    python27 \
    python27-devel \
    python27-pip \
    python27-setuptools
    
    
RUN groupadd -r slcs && adduser -r -g slcs slcs
    
ENV APPLICATION_HOME=/usr/local/esgf-slcs-server
ENV CODE_LOCATION=$APPLICATION_HOME/src/esgf_slcs_server \
    APPLICATION_CONF_DIR=$APPLICATION_HOME/conf/app
    
RUN mkdir -p $CODE_LOCATION && \
    mkdir -p $APPLICATION_CONF_DIR && \
    chown -R slcs:slcs $APPLICATION_HOME && \
    chown -R :slcs /usr/lib/python2.7 && \
    chmod -R g+wx /usr/lib/python2.7 && \
    chown -R :slcs /usr/lib64/python2.7 && \
    chmod -R g+wx /usr/lib64/python2.7 && \
    chown -R :slcs /usr/bin && \
    chmod -R g+wx /usr/bin && \
    chown -R :slcs $APPLICATION_CONF_DIR && \
    chmod -R g+wx $APPLICATION_CONF_DIR

USER slcs
WORKDIR $CODE_LOCATION
ARG ESGF_SLCS_SERVER_VERSION=master
ENV START_HERE=no
RUN git init && \
    git pull https://github.com/fgreg/esgf-slcs-server $ESGF_SLCS_SERVER_VERSION && \
    pip2.7 install -r requirements.txt && \
    pip2.7 install waitress

USER root
COPY settings.py $CODE_LOCATION/esgf_slcs_server/settings.py
RUN chown slcs:slcs $CODE_LOCATION/esgf_slcs_server/settings.py && \
    chmod 644 $CODE_LOCATION/esgf_slcs_server/settings.py
USER slcs
RUN pip2.7 install $CODE_LOCATION
    
RUN touch $APPLICATION_CONF_DIR/secret_key.txt && \
    tr -dc '[:alnum:][:punct:]' < /dev/urandom | head -c 100 > $APPLICATION_CONF_DIR/secret_key.txt && \
    chmod 400 $APPLICATION_CONF_DIR/secret_key.txt
    
VOLUME $APPLICATION_HOME/conf/db
VOLUME $APPLICATION_HOME/conf/ca

ENV SLCS_APPLICATION_HOME=$APPLICATION_HOME \
    SLCS_STATIC_ROOT=/var/www/static


COPY onlineca.ini $APPLICATION_CONF_DIR/onlineca.ini
COPY docker-entrypoint.py /usr/local/bin/docker-entrypoint.py

USER root
RUN chown slcs:slcs $APPLICATION_CONF_DIR/onlineca.ini && \
    chmod 644 $APPLICATION_CONF_DIR/onlineca.ini && \
    mkdir -p $SLCS_STATIC_ROOT && \
    chown -R slcs:slcs $SLCS_STATIC_ROOT && \
    find $SLCS_STATIC_ROOT -type d -exec chmod 755 {} \; && \
    find $SLCS_STATIC_ROOT -type f -exec chmod 644 {} \; && \
    chown slcs:slcs /usr/local/bin/docker-entrypoint.py && \
    chmod 744 /usr/local/bin/docker-entrypoint.py

# install OnlineCA client
RUN pip2.7 install ContrailOnlineCAClient
RUN cd /usr/local && \
    git clone https://github.com/cedadev/online_ca_client.git
# must override onlineca-get-cert.sh script to use --insecure option
COPY scripts/onlineca-get-cert.sh /usr/local/online_ca_client/contrail/security/onlineca/client/sh/onlineca-get-cert.sh

USER slcs
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.py"]
CMD ["--help"]
