#!/usr/bin/env python
# -*- coding: utf-8 -*-

import os
from ConfigParser import ConfigParser


ONLINECA_PASTEDEPLOY_FILE = os.environ['ONLINECA_PASTEDEPLOY_FILE']

# Read in the current state of the pastedeploy file
config = ConfigParser()
with open(ONLINECA_PASTEDEPLOY_FILE) as f:
    config.readfp(f)

# Insert some values from the environment into the config file
config.set(
    'app:main',
    'onlineca.server.ca_class.cert_filepath',
    os.environ['ONLINECA_CERT_FILEPATH']
)
config.set(
    'app:main',
    'onlineca.server.ca_class.key_filepath',
    os.environ['ONLINECA_KEY_FILEPATH']
)
config.set(
    'app:main',
    'onlineca.server.cert_subject_name_template',
    os.environ['ONLINECA_CERT_SUBJECT_TEMPLATE']
)
config.set(
    'app:main',
    'onlineca.server.trustroots_dir',
    os.environ['ONLINECA_TRUSTROOTS_DIR']
)
if 'ONLINECA_CACERT_CHAIN_FILEPATHS' in os.environ:
    config.set(
        'app:main',
        'onlineca.server.cacert_chain_filepaths',
        os.environ['ONLINECA_CACERT_CHAIN_FILEPATHS']
    )

# Write the result back out
with open(ONLINECA_PASTEDEPLOY_FILE, mode = 'w') as f:
    config.write(f)
