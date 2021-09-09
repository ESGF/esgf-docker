#!/bin/bash

##
# This script populates the configuration files for the Keycloak directory
# It allows the Keycloak configuration directory to be mounted as an empty volume
##

# Copy XML configuration
cp /opt/jboss/deploy/standalone-ha.xml /opt/jboss/keycloak/standalone/configuration/

# Ensure required properties files exist
declare -a filenames=("application-roles" "application-users" "logging" "mgmt-groups" "mgmt-users")
for i in "${filenames[@]}"
do
   touch "/opt/jboss/keycloak/standalone/configuration/$i.properties"
done
