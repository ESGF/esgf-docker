#!/bin/bash

set -e

# First, build the /esg/config directory
/esg/bin/build-config.sh /esg/config
# Then build the CoG config directory
/esg/bin/build-config.sh "$COG_CONFIG_DIR"
