#!/bin/bash

set -e

# Before running any commands, export the variables defined in /esg/environment
if [ -f "/esg/environment" ]; then
    export $(grep -v '#' "/esg/environment")
fi

exec "$@"
