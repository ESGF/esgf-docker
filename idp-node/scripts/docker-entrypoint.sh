#!/bin/sh
# script that starts Tomcat then keeps the container running
#
/usr/local/tomcat/bin/catalina.sh start
#
tail -f /dev/null
