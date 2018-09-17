#!/bin/bash

set -eo pipefail

. "$(dirname $BASH_SOURCE)/functions.sh"

#####
## This script takes a single config directory as it's argument
##
## Inside that directory, it looks for special folders named ".defaults" and ".overrides"
##
## The config directory is then populated by first templating each file in ".defaults",
## then templating each file in ".overrides", using gomplate
#####

# First, check that we got an argument
[ -z "$1" ] && error "No config directory given"

# Pass the argument through realpath to canonicalise it
config_dir="$(realpath "$1")"

info "Building configuration in $config_dir"

# We want to maintain the directory structure, and only process files from .defaults
# if they are not overridden
defaults_dir="${config_dir}/.defaults"
overrides_dir="${config_dir}/.overrides"

# Although gomplate has --input-dir and --output-dir options, they do not seem to
# handle nested directories, which we want
# We also want to skip files that already exist when handling defaults

# First, process the files in overrides
if [ -d "$overrides_dir" ]; then
    info "  Processing files from $overrides_dir"
    for override_file in $(find "$overrides_dir" -type f); do
        config_file="${config_dir}/$(realpath --relative-to="$overrides_dir" $override_file)"
        # Make sure the containing directory exists
        mkdir -p "$(dirname "$config_file")"
        # Then template the file using gomplate
        /esg/bin/gomplate -f "$override_file" -o "$config_file"
    done
else
    warn "  $overrides_dir does not exist - skipping"
fi

# Then process the files in defaults, skipping any files that exist in the overrides directory
info "  Processing files from $defaults_dir"
for default_file in $(find "$defaults_dir" -type f); do
    relative_path="$(realpath --relative-to="$defaults_dir" $default_file)"
    config_file="${config_dir}/${relative_path}"
    override_file="${overrides_dir}/${relative_path}"
    if [ -f "$override_file" ]; then
        warn "    $config_file is overridden - skipping"
    else
        # Make sure the containing directory exists
        mkdir -p "$(dirname "$config_file")"
        # Then template the file using gomplate
        /esg/bin/gomplate -f "$default_file" -o "$config_file"
    fi
done
