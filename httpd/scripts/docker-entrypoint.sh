#!/bin/bash
# Script to start apache httpd as part of ESGF services

echo "untar grid certificates"
mkdir /etc/grid-security
tar --same-owner -pxaf /root/archives/grid_security_certs.tar.xz -C /etc/grid-security
chmod -R 664 /etc/grid-security/certificates

# change CoG directory permission
chown -R apache:apache /usr/local/cog

# remove conflicting configuration
rm -f /etc/httpd/conf.d/ssl.conf
rm -f /etc/httpd/conf.d/welcome.conf

# start supervisor --> httpd service
supervisord --nodaemon -c /etc/supervisord.conf
