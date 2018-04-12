#!/bin/bash

#####
## This file contains some handy functions used by all scripts
#####

function bold { tput -T screen bold; echo -n "$1"; tput -T screen sgr0; }
function colored { tput -T screen setaf "$1"; echo -n "$2"; tput -T screen setaf 9; }
function info { GREEN=2; echo "$(bold "$(colored "$GREEN" "[INFO] $1")")"; }
function warn { YELLOW=3; echo "$(bold "$(colored "$YELLOW" "[WARN] $1")")"; }
function error { RED=1; echo "$(bold "$(colored "$RED" "[ERROR] $1")")" 1>&2; exit 1; }

function indent {
    # This function applies the specified indent to lines from stdin and writes
    # back to stdout
    while read -r line; do
        # First echo same spaces, but no newline
        echo -n "$(head -c $1 < /dev/zero | tr "\0" " ")"
        # Then echo the line
        echo "$line"
    done
}
