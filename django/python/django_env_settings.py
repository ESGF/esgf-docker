# -*- coding: utf-8 -*-
"""
This module defines some default Django settings using environment variables.
These settings can then serve as a base for the settings file for a Django project.

The settings are intended to be secure by default.
"""

import os


# Security settings
if int(os.environ.get('DJANGO_DEBUG', '0')):
    DEBUG = True
    # When running in debug mode, allow any host headers
    # This mitigates against a DNS rebinding attack
    # See https://docs.djangoproject.com/en/dev/ref/settings/#allowed-hosts
    ALLOWED_HOSTS = ['*']
else:
    DEBUG = False
    SECURE_CONTENT_TYPE_NOSNIFF = True
    SECURE_BROWSER_XSS_FILTER = True
    SESSION_COOKIE_SECURE = bool(int(os.environ.get('DJANGO_SESSION_COOKIE_SECURE', '1')))
    CSRF_COOKIE_SECURE = bool(int(os.environ.get('DJANGO_CSRF_COOKIE_SECURE', '1')))
    CSRF_COOKIE_HTTPONLY = bool(int(os.environ.get('DJANGO_CSRF_COOKIE_HTTPONLY', '1')))
    X_FRAME_OPTIONS = 'DENY'
    ALLOWED_HOSTS = os.environ['DJANGO_ALLOWED_HOSTS'].split(',')


# Secret key
# In order to support Docker secrets, which can only be mounted as files, we allow
# for the secret key to come from the environment or a file specified using an
# environment variable.
try:
    SECRET_KEY = os.environ['DJANGO_SECRET_KEY']
except KeyError:
    with open(os.environ['DJANGO_SECRET_KEY_FILE']) as f:
        SECRET_KEY = f.read().strip()


# Logging settings
if not DEBUG:
    LOG_FORMAT = '[%(levelname)s] [%(asctime)s] [%(name)s:%(lineno)s] [%(threadName)s] %(message)s'
    LOGGING_CONFIG = None
    LOGGING = {
        'version' : 1,
        'disable_existing_loggers' : False,
        'formatters' : {
            'generic' : {
                'format' : LOG_FORMAT,
            },
        },
        'handlers' : {
            'stdout' : {
                'class' : 'logging.StreamHandler',
                'formatter' : 'generic',
            },
        },
        'loggers' : {
            '' : {
                'handlers' : ['stdout'],
                'level' : 'INFO',
                'propogate' : True,
            },
        },
    }
    import logging.config
    logging.config.dictConfig(LOGGING)


# Database settings
#
# Databases are configured using environment variables of the form DJANGO_DATABASE_<DBNAME>_<PROP>[_FILE].
# Each variable of this format sets an entry in the database dictionary.
# In order to allow values from Docker secrets, which can only be mounted as files,
# the _FILE suffix can be used to specify a file to read the variable from.
DATABASES = {}
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


# Static files settings
# Put static files under the home directory as we know we can write there for collectstatic
STATIC_ROOT = os.path.join(os.environ['HOME'], 'static')
STATIC_URL = '/static/'
