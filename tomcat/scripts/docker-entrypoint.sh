#!/bin/bash

set -eo pipefail

function info { echo "[INFO] $1"; }
function error { echo "[ERROR] $1" 1>&2; exit 1; }

# Make sure the trusted certificates have been updated
info "Updating trusted certificates"
# Split esg-trusted-bundle.pem into separate certificates
# This is required because keytool only imports the first cachain from each file
CERT_DIR=$(mktemp -d)
pushd $CERT_DIR
csplit -z -f 'cert' -b '%03d.crt' /esg/certificates/esg-trust-bundle.pem "/END CERTIFICATE/1" "{*}"
popd
# Add each certificate to the Java truststore using keytool using the hash as the alias
for file in $(find $CERT_DIR -name '*.crt'); do
    alias="$(openssl x509 -hash -noout -in "$file").0"
    # Test if the alias already exists in the keystore, do nothing
    if keytool -list \
               -keystore $JAVA_HOME/lib/security/cacerts -storepass changeit \
               -alias $alias > /dev/null 2>&1; then
        info "  Certificate $alias already imported"
    else
        info "  Importing certificate $alias"
        keytool -import -noprompt \
                -keystore $JAVA_HOME/lib/security/cacerts -storepass changeit \
                -alias $alias -file $file
    fi
done
rm -rf $CERT_DIR

# Execute customisations from /tomcat-init.d before doing anything
info "Running customisations"
if [ -d "/tomcat-init.d" ]; then
    for file in $(find /tomcat-init.d/ -mindepth 1 -type f -executable | sort -n); do
        case "$file" in
            *.sh) . $file ;;
            *) eval $file || exit 1 ;;
        esac
    done
fi

# Just run the given command
info "Starting tomcat"
exec "$@"
