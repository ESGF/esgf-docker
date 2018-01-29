#!/bin/bash

# Execute customisations from /tomcat-init.d before doing anything
# These customisations also run as root, which can be handy
if [ -d "/tomcat-init.d" ]; then
    for file in $(find /tomcat-init.d/ -mindepth 1 -type f -executable | sort -n); do
        # All customisations have access to the exported environment variables only,
        # whether they are bash or otherwise
        # If a customisation fails, the whole container fails
        eval $file || exit 1
    done
fi

# Just run the given command as the tomcat user
exec gosu "$TOMCAT_USER" "$@"
