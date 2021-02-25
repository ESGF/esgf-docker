#!/bin/bash

##
# This script installs a Keycloak theme .jar file from a URL.
##

# Download the theme .jar to the Keycloak themes directory
if [[ -v KEYCLOAK_THEME_JAR_URL ]]; then
    curl $KEYCLOAK_THEME_JAR_URL -L --output /opt/jboss/keycloak/standalone/deployments/custom.jar
fi
