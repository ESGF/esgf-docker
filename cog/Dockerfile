# ESGF node with CoG web application
#
# To run CoG standalone on localhost:
# docker run -ti -p 8000:8000 --name cog $ESGF_IMAGES_HUB/esgf-cog:${ESGF_VERSION}
# To run CoG standalone with a specific hostname:
# docker run -ti -p 8000:8000 --name cog -e ESGF_HOSTNAME=${ESGF_HOSTNAME} $ESGF_IMAGES_HUB/esgf-cog:${ESGF_VERSION} ${ESGF_HOSTNAME} false true
# To map the local source directory:
# docker run -ti -p 8000:8000 --name cog -v /Users/cinquini/Documents/workspace/cog:/usr/local/cog/cog_install $ESGF_IMAGES_HUB/esgf-cog:${ESGF_VERSION}

ARG ESGF_IMAGES_HUB=esgfhub
ARG ESGF_VERSION=devel
FROM $ESGF_IMAGES_HUB/esgf-node:$ESGF_VERSION
MAINTAINER Earth System Grid Federation <esgf-devel@lists.llnl.gov>

# choose CoG version
ENV COG_TAG=v3.9.9

# env variable to execute CoG initialization
# may be overridden from command line after first container startup
ENV INIT=true

# setup CoG environment
ENV COG_DIR=/usr/local/cog
RUN mkdir -p $COG_DIR
ENV COG_CONFIG_DIR=$COG_DIR/cog_config
RUN mkdir -p $COG_CONFIG_DIR
ENV COG_INSTALL_DIR=$COG_DIR/cog_install
RUN mkdir -p $COG_INSTALL_DIR
ENV LD_LIBRARY_PATH=/usr/local/lib

# install Python virtual environment
RUN cd $COG_DIR && \
    virtualenv venv

# download CoG specific tag or branch
RUN cd $COG_DIR && \
    git clone https://github.com/EarthSystemCoG/COG cog_install && \
    cd cog_install && \
    git checkout $COG_TAG
    #git checkout -b devel origin/devel

# install CoG dependencies
RUN cd $COG_INSTALL_DIR && \
    source $COG_DIR/venv/bin/activate && \
    pip install -r requirements.txt

# setup CoG database and configuration
RUN cd $COG_INSTALL_DIR && \
    source $COG_DIR/venv/bin/activate && \
    python setup.py install

# manually install additional dependencies
RUN cd $COG_DIR && \
    source $COG_DIR/venv/bin/activate && \
    git clone https://github.com/EarthSystemCoG/django-openid-auth.git && \
    cd django-openid-auth && \
    python setup.py install

RUN cd $COG_DIR && \
    git clone https://github.com/globusonline/transfer-api-client-python.git && \
    cd transfer-api-client-python && \
    source $COG_DIR/venv/bin/activate && \
    python setup.py install && \
    git pull && \
    cd mkproxy && \
    make  && \
    cp mkproxy $COG_DIR/venv/lib/python2.7/site-packages/globusonline/transfer/api_client/x509_proxy/.

# collect static files to ./static directory
# must use a minimal settings file (configured with sqllite3 database)
COPY conf/cog_settings.cfg /usr/local/cog/cog_config/cog_settings.cfg
RUN cd $COG_INSTALL_DIR && \
    source $COG_DIR/venv/bin/activate && \
    python manage.py collectstatic --no-input && \
    rm /usr/local/cog/cog_config/cog_settings.cfg
    #python setup.py -q setup_cog --esgf=false

# for some unknown reason, must reinstall captcha
#RUN source $COG_DIR/venv/bin/activate && \
#    pip uninstall -y django-simple-captcha && \
#    pip install django-simple-captcha==0.5.1

# expose default django port
EXPOSE 8000

# create non-privileged user to run django
RUN groupadd -r cogadmin && \
    useradd -r -g cogadmin cogadmin && \
    mkdir -p ~cogadmin && \
    chown cogadmin:cogadmin ~cogadmin

# change user prompt
RUN echo 'export PS1="[\u@\h]\$ "' >> ~cogadmin/.bashrc

# change ownership of application directories
#RUN chown -R cogadmin:cogadmin $COG_DIR

# expose software installation directories
# needed by apache httpd running cog through mod_wsgi
VOLUME $COG_DIR/venv
VOLUME $COG_INSTALL_DIR

# startup
COPY  scripts/ /usr/local/bin/
COPY  conf/supervisord.cog.conf /etc/supervisor/conf.d/supervisord.cog.conf
#COPY  scripts/wait_for_postgres.sh /usr/local/bin/wait_for_postgres.sh
#COPY  scripts/process_esgf_config_archive.sh /usr/local/bin/process_esgf_config_archive.sh

# wait for Postgres connection to be ready
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
# will override these CMD options at run time
CMD ["localhost", "false", "true"]
