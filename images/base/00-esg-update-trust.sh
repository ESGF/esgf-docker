#!/usr/bin/bash

set -e

#####
## This script updates the system trust roots with certificates from $ESG_CERT_DIR
#####

echo "[info] Linking certificates from $ESG_CERT_DIR"
for f in $(find $ESG_CERT_DIR -maxdepth 1 -type f); do
    ln -s $f /etc/pki/ca-trust/source/anchors/;
done
echo "[info] Updating system trustroots"
update-ca-trust extract
