#!/bin/sh
# script that starts all the Solr Cloud nodes
#
# Usage: ./solr_cloud_start.sh <optional zkhost>
#
# optional input argument when starting on host that does not include a running ZookKeeper
zkhost=$1

echo "Using zkhost=$zkhost"
if [ "$zkhost" = "" ]; then
   # start first Solr as leader
   $SOLR_CLOUD_INSTALL/solr/bin/solr start -c -p 8983 -s $SOLR_CLOUD_HOME/node8983/solr/  -m 512m
   # connect other Solrs to ZK on localhost
   $SOLR_CLOUD_INSTALL/solr/bin/solr start -c -p 8984 -s $SOLR_CLOUD_HOME/node8984/solr/ -z localhost:9983 -m 512m
   $SOLR_CLOUD_INSTALL/solr/bin/solr start -c -p 8985 -s $SOLR_CLOUD_HOME/node8985/solr/ -z localhost:9983 -m 512m
else
   # connect all Solrs to ZK on given zkhost
   $SOLR_CLOUD_INSTALL/solr/bin/solr start -c -p 8983 -s $SOLR_CLOUD_HOME/node8983/solr/ -z $zkhost:9983 -m 512m 
   $SOLR_CLOUD_INSTALL/solr/bin/solr start -c -p 8984 -s $SOLR_CLOUD_HOME/node8984/solr/ -z $zkhost:9983 -m 512m
   $SOLR_CLOUD_INSTALL/solr/bin/solr start -c -p 8985 -s $SOLR_CLOUD_HOME/node8985/solr/ -z $zkhost:9983 -m 512m
fi
