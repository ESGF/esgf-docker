#!/usr/bin/bash
# Environment variables for containerised tomcat instances

# By default, get CPU and memory limits from the container's cgroup
# Also allow the heap to use 80% of the available memory - this allows space for loaded classes etc.
# See https://medium.com/adorsys/usecontainersupport-to-the-rescue-e77d6cfea712
CATALINA_OPTS="-server -Djava.awt.headless=true -XX:+UseContainerSupport -XX:MaxRAMPercentage=80.0"
CATALINA_OPTS="$CATALINA_OPTS $CATALINA_EXTRA_OPTS"
export CATALINA_OPTS
