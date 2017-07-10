# ESGF node manager
# 
# configuration files:
# /esg/config/esgf.properties : contains all ESGF node properties
# /esg/config/timestamp : used to synchronize updates among nodes
# /esg/config/esgf_supernodes_list.json : list of super nodes, 
#                                         must be periodically updated to reflect the latest status of the federation
# /esg/config/config_type : contains the encoded node type
# 60 for a full node
# 36 for a data node
#
# output files:
# /esg/config/registration.xml
# /esg/log : contains log files
# /esg/tasks : contains update task files in jsoon format
# /esg/config/nm.properties 
# /esg/config/esgf_nodemgr_map.json : periodically updated to reflect nodes status

FROM esgfhub/esgf-node:1.2

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

# FIXME: use 'master' branch instead of 'docker' branch
RUN cd $INST_DIR && \
    git  clone https://github.com/ESGF/esgf-node-manager.git && \
    cd esgf-node-manager && \
    git checkout devel

# install dependencies in Python virtual environment
RUN source $PYTHON_VENV/bin/activate && \ 
    cd $NM_DIR/python && \
    pip install -r requirements.txt

# executables
RUN cp $NM_DIR/scripts/esgf-nm-ctl $INST_DIR/bin/. && \
    chmod u+x $INST_DIR/bin/esgf-nm-ctl $NM_DIR/scripts/esgfnmd 

# add user to run the node manager as
RUN adduser nodemgr && \
    usermod -a -G apache nodemgr

# other needed directories
RUN mkdir /esg/log /esg/tasks

# make Python installation available to Apache httpd + mod_wsgi
VOLUME /opt/esgf/virtual/python
VOLUME /usr/local/esgf-node-manager
VOLUME /esg/log
VOLUME /esg/tasks

# start Node Manager
COPY scripts/docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
