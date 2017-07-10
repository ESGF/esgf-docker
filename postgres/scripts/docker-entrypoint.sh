#!/bin/bash
# Script to start postgres as part of ESGF services

# start supervisor --> postgres service
supervisord -c /etc/supervisord.conf

# keep container running by printing log to standard out
sleep 2
tail -f /var/lib/pgsql/data/pg_log/postgresql.log
