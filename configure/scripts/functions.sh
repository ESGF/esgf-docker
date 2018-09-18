#####
## This file defines some useful bash functions
#####

function info {
    echo "[INFO]  $1"
}

function warn {
    echo "[WARN]  $1" 1>&2
}

function error {
    echo "[ERROR] $1" 1>&2
    exit 1
}
