#!/bin/bash
# Script to start apache httpd as part of ESGF services

# change CoG directory permission
chown -R apache:apache /usr/local/cog

# remove conflicting configuration
rm -f /etc/httpd/conf.d/ssl.conf
rm -f /etc/httpd/conf.d/welcome.conf

# start supervisor --> httpd service
supervisord -c /etc/supervisord.conf

# keep container running by printing log to standard out
sleep 2
tail -f /etc/httpd/logs/error_log
