#!/bin/bash
# Script to start the TDS with ESGF configuration

# deploy esgf config files
/usr/local/bin/process_esgf_config_archive.sh

# startup configuration inherited from esgf-tomcat image
supervisord --nodaemon -c /etc/supervisord.conf
