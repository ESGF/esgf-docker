#!/bin/bash
# Script to start Tomcat through supervisor
# and follow the log file

# start supervisor --> tomcat
supervisord -c /etc/supervisord.conf

# keep container running by printing log to standard output
sleep 2
tail -f /usr/local/tomcat/logs/catalina.out
