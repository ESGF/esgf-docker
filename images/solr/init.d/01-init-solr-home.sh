#!/bin/bash

#####
## Initialise SOLR_HOME if it is empty
#####

set -eo pipefail


# First, make sure the directory exists and is writable
test -d "$SOLR_HOME" || (echo "[error] $SOLR_HOME does not exist" 2>&1; exit 1)
test -w "$SOLR_HOME" || (echo "[error] $SOLR_HOME is not writable by $(id -u):$(id -g)" 2>&1; exit 1)

# Copy files from /opt/solr that are required
test -r "$SOLR_HOME/solr.xml" || cp -a /opt/solr/server/solr/solr.xml "$SOLR_HOME/solr.xml"
test -r "$SOLR_HOME/zoo.cfg" || cp -a /opt/solr/server/solr/zoo.cfg "$SOLR_HOME/zoo.cfg"
