#!/bin/sh
# script that stops all the Solr Cloud nodes

cd $SOLR_CLOUD_HOME

solr/bin/solr stop -all

