#!/bin/bash

__mod_user() {
usermod -G wheel postgres
}

__create_db() {
su --login postgres --command "/usr/bin/postgres -D /var/lib/pgsql/data -p 5432" &
sleep 10
ps aux 

# create super user
su --login - postgres --command "psql -c \"CREATE USER dbsuper with CREATEROLE superuser PASSWORD 'changeit';\""
# create 'esgcet' user
su --login - postgres --command "psql -c \"CREATE USER esgcet PASSWORD 'changeit';\""
# create CoG database
su --login - postgres --command "psql -c \"CREATE DATABASE cogdb;\""
# create ESGF database
su --login - postgres --command "psql -c \"CREATE DATABASE esgcet;\""
# load ESGF schemas
su --login - postgres --command "psql esgcet < /usr/local/bin/esgf_esgcet.sql"
su --login - postgres --command "psql esgcet < /usr/local/bin/esgf_node_manager.sql"
su --login - postgres --command "psql esgcet < /usr/local/bin/esgf_security.sql"
# load ESGF data
su --login - postgres --command "psql esgcet < /usr/local/bin/esgf_security_data.sql"
# list database users
su --login - postgres --command "psql -c \"\du;\""
# initialize migration table
su --login - postgres --command "psql esgcet < /usr/local/bin/esgf_migrate_version.sql"
}

# Call functions
__mod_user
__create_db
