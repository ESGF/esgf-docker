#!/bin/bash

set -eo pipefail

function info { echo "[INFO] $1"; }
function error { echo "[ERROR] $1" 1>&2; exit 1; }

# Make sure the trusted certificates have been updated
# The openjdk image should have installed a hook that updates the Java SSL truststore
info "Updating trusted certificates"
# Split esg-trusted-bundle.pem into separate certificates in the ca-certificates directory
# used by update-ca-certificates
# This is required because keytool only imports the first cachain from each file
pushd /usr/local/share/ca-certificates
csplit -z -f 'cert' -b '%03d.crt' /esg/certificates/esg-trust-bundle.pem "/END CERTIFICATE/1" "{*}"
popd
update-ca-certificates

# Execute customisations from /tomcat-init.d before doing anything
# These customisations also run as root, which can be handy
info "Running customisations"
if [ -d "/tomcat-init.d" ]; then
    for file in $(find /tomcat-init.d/ -mindepth 1 -type f -executable | sort -n); do
        case "$file" in
            *.sh) . $file ;;
            *) eval $file || exit 1 ;;
        esac
    done
fi

# Just run the given command as the tomcat user
info "Starting tomcat"
exec gosu "$TOMCAT_USER" "$@"
