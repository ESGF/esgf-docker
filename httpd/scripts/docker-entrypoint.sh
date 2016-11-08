#!/bin/bash
# script to start httpd as part of ESGF services

# change CoG directory permission
chown -R apache:apache /usr/local/cog

# remove conflicting configuration
rm -f /etc/httpd/conf.d/ssl.conf
rm -f /etc/httpd/conf.d/welcome.conf

# start httpd service
service httpd restart

# keep container running
tail -f /etc/httpd/logs/error_log
