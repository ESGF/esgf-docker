#!/bin/bash

set -eo pipefail

. "$(dirname $BASH_SOURCE)/functions.sh"

#####
## This script takes a single config directory as it's argument
##
## Inside that directory, it looks for special folders named ".defaults" and ".overrides"
##
## The config directory is then populated by first templating each file in ".defaults",
## then templating each file in ".overrides", using gomplate
#####

# First, check that we got an argument
[ -z "$1" ] && error "No config directory given"

# Pass the argument through realpath to canonicalise it
config_dir="$(realpath "$1")"

info "Building configuration in $config_dir"

info "Using environment:"
env | grep -v "_PASSWORD$"

# First, process the .defaults directory in the root, then the same with .overrides
sources=(".defaults"  ".overrides")
for source in "${sources[@]}"; do
    source_dir="$config_dir/$source"
    if [ -d "$source_dir" ]; then
        info "Processing templates from $source_dir"
        /esg/bin/gomplate --input-dir="$source_dir" --output-dir="$config_dir"
    else
        warn "$source_dir does not exist - skipping"
    fi
done
