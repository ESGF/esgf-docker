#!/bin/bash

#####
## This file contains some handy functions used by all scripts
#####

function bold { tput -T screen bold; echo -n "$1"; tput -T screen sgr0; }
function colored { tput -T screen setaf "$1"; echo -n "$2"; tput -T screen setaf 9; }
function info { GREEN=2; echo "$(bold "$(colored "$GREEN" "[INFO] $1")")"; }
function warn { YELLOW=3; echo "$(bold "$(colored "$YELLOW" "[WARN] $1")")"; }
function error { RED=1; echo "$(bold "$(colored "$RED" "[ERROR] $1")")" 1>&2; exit 1; }

function indent {
    # This function applies the specified indent to lines from stdin and writes
    # back to stdout
    while read -r line; do
        # First echo same spaces, but no newline
        echo -n "$(head -c $1 < /dev/zero | tr "\0" " ")"
        # Then echo the line
        echo "$line"
    done
}

function yaml2json {
    python -c 'import sys, yaml, json; print json.dumps(yaml.load(sys.stdin))'
}
function json2yaml {
    python -c 'import sys, yaml, json; print yaml.safe_dump(json.load(sys.stdin), default_style="|", default_flow_style=False)'
}
function merge_yaml {
    # Convert the source files to JSON
    JSON1="$(mktemp)"
    JSON2="$(mktemp)"
    yaml2json < "$1" > "$JSON1"
    yaml2json < "$2" > "$JSON2"
    # Merge the JSON sources using jq and convert the result back to YAML
    jq -s '.[0] * .[1]' "$JSON1" "$JSON2" | json2yaml
}
