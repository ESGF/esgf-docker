#!/bin/bash

set -e

# First, build the /esg/config directory
/esg/bin/build-config.sh /esg/config
# Then build the /esg/auth config directory
/esg/bin/build-config.sh /esg/auth
