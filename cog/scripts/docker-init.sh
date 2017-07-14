#!/bin/bash
# CoG initialization script
# must be run when CoG is first started or when CoG must be updated

# command line arguments

# ESGF_HOSTNAME=.....
export ESGF_HOSTNAME=$1
echo "ESGF_HOSTNAME=$ESGF_HOSTNAME"

# esgf_flag=false/true
export ESGF_FLAG=$2
echo "ESGF_FLAG=$ESGF_FLAG"

# use virtualenv
source $COG_DIR/venv/bin/activate

# upgrade CoG
cd $COG_INSTALL_DIR
python setup.py -q setup_cog --esgf=$ESGF_FLAG

# customize CoG settings
echo "Using ESGF_HOSTNAME=$ESGF_HOSTNAME"
sed -i 's/ALLOWED_HOSTS = .*/ALLOWED_HOSTS = '"${ESGF_HOSTNAME}"'/g' $COG_CONFIG_DIR/cog_settings.cfg

# FIXME:  PRODUCTION_SERVER = True would require use of SSL to transmit any cookie
sed -i 's/PRODUCTION_SERVER = True/PRODUCTION_SERVER = False/g' $COG_CONFIG_DIR/cog_settings.cfg
