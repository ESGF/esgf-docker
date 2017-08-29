#!/bin/bash
# script containing env variables for starting ESGF Tomcat

export JAVA_OPTS="-Dtds.content.root.path=/esg/content"
#export JAVA_OPTS="-Djavax.net.debug=ssl -Dtds.content.root.path=/esg/content"
export CATALINA_OPTS="-Xmx2048m -server -Xms1024m -XX:MaxPermSize=512m -Dsun.security.ssl.allowUnsafeRenegotiation=false -Djavax.net.ssl.trustStore='/esg/config/tomcat/esg-truststore.ts' -Djavax.net.ssl.trustStorePassword='changeit'"
