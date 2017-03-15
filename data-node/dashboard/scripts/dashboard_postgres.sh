#!/bin/bash
# Script to install the dashboard component of the ESGF monitoring system)
# Author: CMCC (sandro.fiore@cmcc.it)
# Creation date: 20/09/2016
# Last update: 08/12/2016 by CMCC

cd /usr/local

psql -d esgcet -h esgf-postgres -U dbsuper < esgf-dashboard/src/python/esgf/esgf-dashboard/schema_migration/versions/007_postgres_upgrade.sql
psql -d esgcet -h esgf-postgres -U dbsuper < esgf-dashboard/src/python/esgf/esgf-dashboard/schema_migration/versions/008_postgres_upgrade.sql

filename="/esg/config/esgf.properties"
declare regex="esgf.host="
while IFS='' read -r line || [[ -n "$line" ]]; do
if [[ " $line " =~ $regex ]]
    then
        host=`echo $line | cut -d \= -f 2`
        size=${#host}
fi
done < "$filename"

sed "s/FQDN/$size/g" esgf-dashboard/src/python/esgf/esgf-dashboard/schema_migration/versions/009_postgres_upgrade.sql > esgf-dashboard/src/python/esgf/esgf-dashboard/schema_migration/versions/009_postgres_upgrade_new.sql

mv esgf-dashboard/src/python/esgf/esgf-dashboard/schema_migration/versions/009_postgres_upgrade_new.sql esgf-dashboard/src/python/esgf/esgf-dashboard/schema_migration/versions/009_postgres_upgrade.sql

psql -d esgcet -h esgf-postgres -U dbsuper < esgf-dashboard/src/python/esgf/esgf-dashboard/schema_migration/versions/009_postgres_upgrade.sql

psql -d esgcet -h esgf-postgres -U dbsuper < esgf-dashboard/src/python/esgf/esgf-dashboard/schema_migration/versions/010_postgres_upgrade.sql
