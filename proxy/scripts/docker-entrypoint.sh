#!/bin/bash

set -e

# Extract the nameserver from /etc/resolv.conf for the Nginx resolver statement
export ESGF_RESOLVER="$(grep nameserver /etc/resolv.conf | awk '{ print $2; }')"

# Template the Nginx config directory
/esg/bin/build-config.sh /etc/nginx/conf.d

# Run the given command, usually "nginx -g daemon off;"
# If we are not root, run the command using authbind to allow binding to 80 and 443
echo "[INFO] Running command"
if [ "$(id -u)" = "0" ]; then
    exec "$@"
else
    exec authbind --deep "$@"
fi
