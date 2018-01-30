#!/bin/bash

# Execute customisations from /tomcat-init.d before doing anything
# These customisations also run as root, which can be handy
if [ -d "/tomcat-init.d" ]; then
    for file in $(find /tomcat-init.d/ -mindepth 1 -type f -executable | sort -n); do
        case "$file" in
            *.sh) . $file ;;
            *) eval $file || exit 1 ;;
        esac
    done
fi

# Just run the given command as the tomcat user
exec gosu "$TOMCAT_USER" "$@"
