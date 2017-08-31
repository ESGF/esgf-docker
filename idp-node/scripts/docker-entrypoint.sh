#!/bin/bash
# Script to start ESGF IdP

# Must first wait untill connection to the Postgres container is ready
export PGPASSWORD=`cat /esg/config/.esg_pg_pass`
while ! psql -h esgf-postgres -U dbsuper -d esgcet -c "select 1" > /dev/null 2>&1; do
        echo 'Waiting for connection with postgres...'
        sleep 1;
done;
echo 'Connected to postgres...'

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
