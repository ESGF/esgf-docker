#!/usr/bin/bash

set -eo pipefail

#####
## This script updates the system trust roots with certificates from $ESGF_CERT_DIR
#####

if [ ! -d "$ESGF_CERT_DIR" ]; then
    echo "[info] No certificate directory - skipping"
    return
fi

echo "[info] Linking certificates from $ESGF_CERT_DIR"
for f in $(find $ESGF_CERT_DIR -maxdepth 1 -type f); do
    ln -s $f /etc/pki/ca-trust/source/anchors/;
done
echo "[info] Updating system trustroots"
update-ca-trust extract
