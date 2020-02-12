#!/bin/bash

set -eo pipefail;

# Look for scripts in the init directory and execute them in lexicograhpical order
# Bash scripts are sourced, any other executable script is just executed
echo "[info] Running pre-init customisations from $ESG_INIT_DIR"
if [ -d "$ESG_INIT_DIR" ]; then
    for file in $(find $ESG_INIT_DIR -mindepth 1 -type f -executable | sort -n); do
        echo "[info] Running customisations from $file"
        case "$file" in
            *.sh) source $file ;;
            *) eval $file ;;
        esac
    done
fi

# Then start the given process
exec "$@"
