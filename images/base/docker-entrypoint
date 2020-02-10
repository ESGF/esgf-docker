#!/bin/bash

set -eo pipefail;

# Look for scripts in /docker-init.d and execute them in lexicograhpical order
# Bash scripts are sourced, any other executable script is just executed
if [ -d "/docker-init.d" ]; then
    for file in $(find /docker-init.d/ -mindepth 1 -type f -executable | sort -n); do
        case "$file" in
            *.sh) source $file ;;
            *) eval $file ;;
        esac
    done
fi

# Then start the given process
exec "$@"
