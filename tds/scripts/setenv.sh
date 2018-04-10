#!/bin/bash

export JAVA_OPTS="-Dtds.content.root.path=/esg/content"
export CATALINA_OPTS="-Xmx256m -server -Xms256m -XX:MaxPermSize=256m"
