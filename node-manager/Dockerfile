# ESGF node manager

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

# install dependencies in Python virtual environment
COPY conf/requirements.txt /tmp/.
RUN cd /tmp && \
    source $PYTHON_VENV/bin/activate && \
    pip install -r requirements.txt

# install node manager from GitHub repo
ENV INST_DIR /usr/local
ENV NM_DIR $INST_DIR/esgf-node-manager/src

# FIXME: use 'master' branch
RUN cd $INST_DIR && \
    git clone https://github.com/ESGF/esgf-node-manager.git && \
    cd esgf-node-manager && \
    git checkout docker

# custom configuration for node manager
# FIXME: this must be done outside of image creation once the $ESGF_HOSTNAME has been set
ENV ESGF_HOSTNAME my-node.esgf.org
RUN cd $NM_DIR && \
    d=`date` && \
    sk=`echo $d $ESGF_HOSTNAME | sha256sum | awk '{print $1}'` && \
    sed -i s/changeme1/$sk/ python/server/nodemgr/nodemgr/settings.py && \
    sed -i s/changeme2/$ESGF_HOSTNAME/ python/server/nodemgr/nodemgr/settings.py

# executables
# NOTE: must replace LD_LIBRARY_PATH in esgfnmd (note use of sed with ':' delimiter)
RUN cp $NM_DIR/scripts/esgf-nm-ctl $INST_DIR/bin/. && \
    chmod u+x $INST_DIR/bin/esgf-nm-ctl $NM_DIR/scripts/esgfnmd && \
    sed -i s:/opt/esgf/python/lib:/usr/local/lib: $NM_DIR/scripts/esgfnmd

# set proper file permissions
RUN adduser nodemgr && \
    usermod -a -G apache nodemgr

RUN mkdir -p /esg/log /esg/tasks /esg/config && \
    touch /esg/log/django.log && \
    touch /esg/log/esgf_nm.log && \
    touch /esg/log/esgf_nm_dj.log && \
    touch /esg/log/esgfnmd.out.log && \
    touch /esg/log/esgfnmd.err.log && \
    touch /esg/config/nm.properties && \
    touch /esg/config/registration.xml

# FED_NAME=esgf-test
# get -O /esg/config/timestamp http://aims1.llnl.gov/nm-cfg/timestamp
# wget -O /esg/config/esgf_supernodes_list.json http://aims1.llnl.gov/nm-cfg/$FED_NAME/esgf_supernodes_list.json
#COPY conf/timestamp /esg/config/timestamp
#COPY conf/esgf_supernodes_list.json /esg/config/esgf_supernodes_list.json

RUN chown nodemgr:nodemgr /esg/log/esgf_nm.log && \
    chown nodemgr:nodemgr /esg/log/esgfnmd.out.log && \
    chown nodemgr:nodemgr /esg/log/esgfnmd.err.log && \
    chown nodemgr:apache /esg/config/nm.properties && \
    chown nodemgr:apache /esg/config/registration.xml && \
    #chown nodemgr:nodemgr /esg/config/timestamp && \
    #chown nodemgr:nodemgr /esg/config/esgf_supernodes_list.json && \
    chmod 777 /esg/tasks && \
    chown nodemgr:nodemgr $NM_DIR/scripts/esgfnmd && \
    chown apache:apache /esg/log/esgf_nm_dj.log && \
    chown apache:apache /esg/log/django.log

# FIXME: do after image is created using site-specific value
# generate the nodemap
#COPY conf/esgf_supernodes_list.json /esg/config/esgf_supernodes_list.json
#RUN cd $NM_DIR/python/server && \
#    python gen_nodemap.py INIT $ESGF_HOSTNAME && \
#    chmod 755 /esg/config/esgf_nodemgr_map.json && \
#    chown nodemgr:nodemgr /esg/config/esgf_nodemgr_map.json && \
#    chmod a+r /esg/config/esgf_nodemgr_map.json

#COPY conf/esgf_nodemgr_map.json /esg/config/esgf_nodemgr_map.json
#RUN chmod 755 /esg/config/esgf_nodemgr_map.json && \
#    chown nodemgr:nodemgr /esg/config/esgf_nodemgr_map.json && \
#    chmod a+r /esg/config/esgf_nodemgr_map.json

# FIXME
#COPY conf/config_type /esg/config/config_type

# FIXME: fix the source code to NOT hard-wire postgres on localhost
#COPY src/python/server/query.py  /usr/local/esgf-node-manager/src/python/server/query.py
#COPY src/python/server/nodemgr/nodemgr/nodemap.py /usr/local/esgf-node-manager/src/python/server/nodemgr/nodemgr/nodemap.py
#COPY src/python/server/nodemgr/nodemgr/site_profile.py /usr/local/esgf-node-manager/src/python/server/nodemgr/nodemgr/site_profile.py
#COPY src/python/server/supernode.py /usr/local/esgf-node-manager/src/python/server/supernode.py

# make Python installation available to Apache httpd + mod_wsgi
VOLUME /opt/esgf/virtual/python
VOLUME /usr/local/esgf-node-manager
VOLUME /esg/log
VOLUME /esg/tasks

# start Node Manager
COPY scripts/docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
#ENTRYPOINT ["/bin/bash"]
#ENTRYPOINT ["tail", "-f", "/dev/null"]
