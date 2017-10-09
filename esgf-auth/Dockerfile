# ESGF-Auth client application.

ARG ESGF_IMAGES_HUB=esgfhub
ARG ESGF_VERSION=devel
ARG ESGF_REPO=http://distrib-coffee.ipsl.jussieu.fr/pub/esgf

FROM $ESGF_IMAGES_HUB/esgf-node:$ESGF_VERSION

MAINTAINER Earth System Grid Federation <esgf-devel@lists.llnl.gov>

# library dependencies
RUN yum -y update; yum -y install libffi-devel; yum clean all

# create python virtual environment
RUN mkdir -p /usr/local/esgf-auth && \
    cd /usr/local/esgf-auth && \
    virtualenv venv

# install source code
RUN mkdir -p /usr/local/esgf-auth/src

# install crypto cookie
RUN cd /usr/local/esgf-auth && \
    source venv/bin/activate && \
    cd src && \
    git clone https://github.com/philipkershaw/crypto-cookie.git && \
    cd /usr/local/esgf-auth/src/crypto-cookie && \
    python setup.py install

# install esgf-auth
RUN cd /usr/local/esgf-auth && \
    source venv/bin/activate && \
    cd src && \
    git clone https://github.com/lukaszlacinski/esgf-auth.git && \
    cd /usr/local/esgf-auth/src/esgf-auth && \
    pip install -r requirements.txt && \
    pip install paste && \
    python manage.py migrate

# FIXME: must make database writable by user apache
#RUN chmod a+w /usr/local/esgf-auth/src/esgf-auth/db.sqlite3

# start esgf-auth through supervisor
#ADD esgf-auth/conf/supervisord.esgf-auth.conf /etc/supervisor/conf.d/supervisord.esgf-auth.conf

EXPOSE 8001
VOLUME /usr/local/esgf-auth

#===========================================

# startup configuration inherited from esgf-tomcat image
CMD ["supervisord", "--nodaemon", "-c", "/etc/supervisord.conf"]
