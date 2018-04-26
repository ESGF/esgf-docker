# -*- coding: utf-8 -*-
"""
Settings wrapper for the ESGF Auth WSGI application.
"""

# Start with the default settings
from esgf_auth.settings import *

# Override the database settings if the environment variables are set
for name, value in os.environ.items():
    if not name.startswith('DJANGO_DATABASE_'):
        continue
    name = name[16:]
    # Allow for the _FILE suffix
    if name.endswith('_FILE'):
        name = name[:-5]
        with open(value) as f:
            value = f.read().strip()
    # Set the item in DATABASES
    db, prop = name.split('_')
    DATABASES.setdefault(db.lower(), {})[prop] = value


# Configure staticfiles app
STATICFILES_DIRS = [
    os.environ['ESGF_AUTH_INSTALL_DIR'] + '/static',
]
STATIC_ROOT = os.environ['DJANGO_STATIC_ROOT']
# Check if we are running under a prefix
if 'SCRIPT_NAME' in os.environ:
    STATIC_URL = STATIC_URL.replace('/esgf-auth', os.environ['SCRIPT_NAME'])
