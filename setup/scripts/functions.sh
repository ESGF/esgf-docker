#!/bin/bash

#####
## This file contains some handy functions used by all scripts
#####

function bold { tput -T screen bold; echo -n "$1"; tput -T screen sgr0; }
function colored { tput -T screen setaf "$1"; echo -n "$2"; tput -T screen setaf 9; }
function info { GREEN=2; echo "$(bold "$(colored "$GREEN" "[INFO] $1")")"; }
function warn { YELLOW=3; echo "$(bold "$(colored "$YELLOW" "[WARN] $1")")"; }
function error { RED=1; echo "$(bold "$(colored "$RED" "[ERROR] $1")")"; exit 1; }
