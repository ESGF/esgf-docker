#!/bin/bash

set -e

# Before running any commands, export the variables defined in /esg/environment
if [ -f "/esg/environment" ]; then
    # "set -a" means that every variable that is assigned until "set +a" is
    # automatically exported
    set -a
    source /esg/environment
    set +a
fi

exec "$@"
