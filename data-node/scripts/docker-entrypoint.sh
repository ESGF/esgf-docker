#!/bin/bash
# Default script to start Tomcat inside a container

# start Tomcat in the background (so it can be restarted without stopping the container)
# note: additional startup parameters are read from bin/setenv.sh
$CATALINA_HOME/bin/catalina.sh start

# keep container running by printing log to standard output
logfile=/usr/local/tomcat/logs/catalina.out
while ! [ -f $logfile ];
do
    sleep 1
done
tail -f $logfile
