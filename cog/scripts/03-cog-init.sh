#!/bin/bash

set -e

# Run the CoG initial setup
# This should be idempotent, so it shouldn't matter if it is run multiple times
echo "[INFO] Running CoG setup"
cd $COG_INSTALL_DIR
python setup.py -q setup_cog --esgf="True"

# TODO: FIX THE CHANGE_PASSWORD COMMAND

# Update the rootAdmin password to match the current environment variable using the manage command
#if [ -z "$ESGF_ROOTADMIN_PASSWORD" ]; then
#    [ -z "$ESGF_ROOTADMIN_PASSWORD_FILE" ] && \
#        error "ESGF_ROOTADMIN_PASSWORD or ESGF_ROOTADMIN_PASSWORD_FILE must be specified"
#    [ ! -f "$ESGF_ROOTADMIN_PASSWORD_FILE" ] && \
#        error "ESGF_ROOTADMIN_PASSWORD_FILE does not exist"
#    ESGF_ROOTADMIN_PASSWORD="$(cat "$ESGF_ROOTADMIN_PASSWORD_FILE")"
#fi
#python manage.py change_password "${ESGF_IDP_URL}/esgf-idp/openid/rootAdmin" "${ESGF_ROOTADMIN_PASSWORD}"
