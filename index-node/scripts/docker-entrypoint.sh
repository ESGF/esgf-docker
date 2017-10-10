#!/bin/bash
# Script to start ESGF data node

# deploy esgf config files
/usr/local/bin/process_esgf_config_archive.sh

# index node startup configuration inherited from esgf-tomcat image
supervisord --nodaemon -c /etc/supervisord.conf
