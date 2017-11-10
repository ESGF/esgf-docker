#!/bin/bash
# Script to start the TDS with ESGF configuration

# deploy the ESGF trusted certificates
echo "untar grid certificates"
mkdir /etc/grid-security
tar --same-owner -pxaf /root/archives/grid_security_certs.tar.xz -C /etc/grid-security
chmod -R 664 /etc/grid-security/certificates

# deploy esgf config files
/usr/local/bin/process_esgf_config_archive.sh

# start supervisor to keep the container going
supervisord --nodaemon -c /etc/supervisord.conf
