#!/bin/bash

# deploy esgf config files
/usr/local/bin/process_esgf_config_archive.sh

# start supervisor to keep the container going
supervisord --nodaemon -c /etc/supervisord.conf
