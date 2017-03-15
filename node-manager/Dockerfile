# ESGF node manager
# 
# configuration files:
# /esg/config/esgf.properties : contains all ESGF node properties
# /esg/config/timestamp : used to synchronize updates among nodes
# /esg/config/esgf_supernodes_list.json : list of super nodes, 
#                                         must be periodically updated to reflect the latest status of the federation
# /esg/config/config_type : contains the encoded node type
#
# outout files:
# /esg/config/registration.xml
# /esg/log : contains log files
# /esg/tasks : contains update task files in jsoon format
# /esg/config/nm.properties 
# /esg/config/esgf_nodemgr_map.json : periodically updated to reflect nodes status

FROM esgfhub/esgf-node:1.1

MAINTAINER Luca Cinquini <luca.cinquini@jpl.nasa.gov>

# install libs dependencies
RUN yum -y update && \
    yum -y install postgresql-devel postgresql postgresql-libs mod_ssl && \
    yum clean all

# create Python virtual environment
RUN mkdir -p /opt/esgf/virtual && \
    cd /opt/esgf/virtual && \
    virtualenv python
ENV PYTHON_VENV=/opt/esgf/virtual/python

# install node manager from GitHub repo
ENV INST_DIR /usr/local
ENV NM_DIR $INST_DIR/esgf-node-manager/src

# FIXME: use 'master' branch instead of 'docker'
RUN cd $INST_DIR && \
    git  clone https://github.com/ESGF/esgf-node-manager.git && \
    cd esgf-node-manager && \
    git checkout docker

# install dependencies in Python virtual environment
RUN source $PYTHON_VENV/bin/activate && \ 
    cd $NM_DIR/python && \
    pip install -r requirements.txt

# executables
RUN cp $NM_DIR/scripts/esgf-nm-ctl $INST_DIR/bin/. && \
    chmod u+x $INST_DIR/bin/esgf-nm-ctl $NM_DIR/scripts/esgfnmd 

# set proper file permissions
RUN adduser nodemgr && \
    usermod -a -G apache nodemgr

#RUN mkdir -p /esg/log /esg/tasks /esg/config && \
#    touch /esg/log/django.log && \
#    touch /esg/log/esgf_nm.log && \
#    touch /esg/log/esgf_nm_dj.log && \
#    touch /esg/log/esgfnmd.out.log && \
#    touch /esg/log/esgfnmd.err.log && \
#    touch /esg/config/nm.properties && \
#    touch /esg/config/registration.xml && \
#    chown nodemgr:nodemgr /esg/log/esgf_nm.log && \
#    chown nodemgr:nodemgr /esg/log/esgfnmd.out.log && \
#    chown nodemgr:nodemgr /esg/log/esgfnmd.err.log && \
#    chown nodemgr:apache /esg/config/nm.properties && \
#    chown nodemgr:apache /esg/config/registration.xml && \
#    #chown nodemgr:nodemgr /esg/config/timestamp && \
#    #chown nodemgr:nodemgr /esg/config/esgf_supernodes_list.json && \
#    chmod 777 /esg/tasks && \
#    chown nodemgr:nodemgr $NM_DIR/scripts/esgfnmd && \
#    chown apache:apache /esg/log/esgf_nm_dj.log && \
#    chown apache:apache /esg/log/django.log

# make Python installation available to Apache httpd + mod_wsgi
VOLUME /opt/esgf/virtual/python
VOLUME /usr/local/esgf-node-manager
VOLUME /esg/log
VOLUME /esg/tasks

# start Node Manager
COPY scripts/docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
