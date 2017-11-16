# ESGF-Auth client application.

ARG ESGF_IMAGES_HUB=esgfhub
ARG ESGF_VERSION=devel
ARG ESGF_REPO=http://distrib-coffee.ipsl.jussieu.fr/pub/esgf

FROM $ESGF_IMAGES_HUB/esgf-node:$ESGF_VERSION
MAINTAINER Earth System Grid Federation <esgf-devel@lists.llnl.gov>

# installation directory
ENV ESGF_AUTH_INSTALL_DIR=/usr/local/esgf-auth

# library dependencies
RUN yum -y update; yum -y install libffi-devel; yum clean all

# create python virtual environment
RUN mkdir -p $ESGF_AUTH_INSTALL_DIR && \
    cd $ESGF_AUTH_INSTALL_DIR && \
    virtualenv venv

# install source code
RUN mkdir -p $ESGF_AUTH_INSTALL_DIR/src

# install crypto cookie
RUN cd $ESGF_AUTH_INSTALL_DIR && \
    source venv/bin/activate && \
    cd src && \
    git clone https://github.com/philipkershaw/crypto-cookie.git && \
    cd crypto-cookie && \
    python setup.py install

# copy mock configuration file which is read by settings.py during the database creation
COPY conf/esgf_auth_config.json /esg/config/esgf_auth_config.json

# install esgf-auth
RUN cd $ESGF_AUTH_INSTALL_DIR && \
    source venv/bin/activate && \
    cd src && \
    git clone https://github.com/ESGF/esgf-auth.git && \
    cd esgf-auth && \
    pip install -r requirements.txt && \
    python ./manage.py migrate

# change permission on parent directory and database file so user apache can write
RUN chmod a+w /usr/local/esgf-auth/src/esgf-auth && \
    chmod a+w /usr/local/esgf-auth/src/esgf-auth/db.sqlite3

VOLUME /usr/local/esgf-auth

CMD ["supervisord", "--nodaemon", "-c", "/etc/supervisord.conf"]
