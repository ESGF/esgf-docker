#!/bin/bash
# Script to start ESGF IdP

# deploy esgf config files
/usr/local/bin/process_esgf_config_archive.sh

# start supervisor --> httpd service
supervisord --nodaemon -c /etc/supervisord.conf