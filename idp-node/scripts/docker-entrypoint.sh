#!/bin/bash
# Script to start ESGF IdP

/usr/local/bin/process_esgf_config_archive.sh

# start supervisor --> httpd service
supervisord --nodaemon -c /etc/supervisord.conf