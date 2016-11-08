# ESGF node with CoG web application
# When running a container, must have $ESGF_HOSTNAME ebv set,

FROM esgfhub/esgf-node

MAINTAINER Luca Cinquini <luca.cinquini@jpl.nasa.gov>

# choose CoG version
ENV COG_TAG=v3.7.0

# setup CoG environment
ENV COG_DIR=/usr/local/cog
RUN mkdir -p $COG_DIR
ENV COG_CONFIG_DIR=$COG_DIR/cog_config
RUN mkdir -p $COG_CONFIG_DIR
ENV COG_INSTALL_DIR=$COG_DIR/cog_install
RUN mkdir -p $COG_INSTALL_DIR
ENV LD_LIBRARY_PATH=/usr/local/lib

# install CoG in virtual environment
RUN cd $COG_DIR && \
    virtualenv venv && \
    source $COG_DIR/venv/bin/activate && \
    git  clone https://github.com/EarthSystemCoG/COG cog_install

# checkout specific tag or branch
RUN cd $COG_INSTALL_DIR && \
    git checkout -b devel origin/devel
    #git checkout $COG_TAG

# install CoG dependencies
RUN cd $COG_INSTALL_DIR && \
    source $COG_DIR/venv/bin/activate && \
    python setup.py -q install

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
    cp mkproxy $COG_DIR/venv/lib/python2.7/site-packages/globusonline_transfer_api_client-0.10.18-py2.7.egg/globusonline/transfer/api_client/x509_proxy/.

# for some unknown reason, must reinstall captcha
RUN source $COG_DIR/venv/bin/activate && \
    pip uninstall -y django-simple-captcha && \
    pip install django-simple-captcha==0.5.1

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
RUN chown -R cogadmin:cogadmin $COG_DIR

# expose software installation directories
# needed by apache httpd running cog through mod_wsgi
VOLUME $COG_DIR/venv
VOLUME $COG_INSTALL_DIR

# scripts
COPY scripts/ /usr/local/bin/
RUN chmod +x /usr/local/bin/*.sh

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD ["false", "true"]
