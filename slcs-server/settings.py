# -*- coding: utf-8 -*-
"""
Django settings for the ESGF SLCS Server.
"""

import os
from django.core.urlresolvers import reverse_lazy

# Build paths inside the project like this: os.path.join(BASE_DIR, ...)
BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
APPLICATION_HOME = os.environ['SLCS_APPLICATION_HOME']

ALLOWED_HOSTS = ['localhost', '127.0.0.1', os.environ['SLCS_SERVER_NAME']]
USE_X_FORWARDED_HOST = "true" == str(os.getenv('SLCS_USE_X_FORWARDED_HOST')).lower()

DEBUG = "true" == str(os.getenv('SLCS_DJANGO_DEBUG_MODE')).lower()

# Security settings
if not DEBUG:
    SECURE_CONTENT_TYPE_NOSNIFF = True
    SECURE_BROWSER_XSS_FILTER = True
    SESSION_COOKIE_SECURE = True
    CSRF_COOKIE_SECURE = True
    CSRF_COOKIE_HTTPONLY = True
    X_FRAME_OPTIONS = 'DENY'

# Read the secret key from a file
SECRET_KEY_FILE = '{0}/conf/app/secret_key.txt'.format(APPLICATION_HOME)
with open(SECRET_KEY_FILE) as f:
    SECRET_KEY = f.read().strip()

# Logging settings
DEFAULT_FROM_EMAIL = SERVER_EMAIL = os.environ['SLCS_SERVER_EMAIL']


if not DEBUG:
    if 'SLCS_ADMINS' in os.environ.keys() and '' != os.environ['SLCS_ADMINS']:
        ADMINS = [ (name_email.split(',')[0], name_email.split(',')[1]) for name_email in os.environ['SLCS_ADMINS'].split(';')]

    LOGGING_CONFIG = None
    LOGGING = {
        'version' : 1,
        'disable_existing_loggers' : False,
        'formatters' : {
            'generic' : {
                'format' : '[%(levelname)s] [%(asctime)s] [%(name)s:%(lineno)s] [%(threadName)s] %(message)s',
            },
        },
        'handlers' : {
            'stdout' : {
                'class' : 'logging.StreamHandler',
                'formatter' : 'generic',
            },
            'mail_admins' : {
                'class' : 'django.utils.log.AdminEmailHandler',
                'formatter' : 'generic',
                'level' : 'ERROR',
            },
        },
        'loggers' : {
            '' : {
                'handlers' : ['stdout', 'mail_admins'],
                'level' : 'INFO',
                'propogate' : True,
            },
        },
    }
    import logging.config
    logging.config.dictConfig(LOGGING)


# Application definition

INSTALLED_APPS = [
    'django.contrib.admin',
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.messages',
    'django.contrib.staticfiles',
    'oauth2_provider',
    'bootstrap3',
]

MIDDLEWARE_CLASSES = [
    'django.middleware.security.SecurityMiddleware',
    'django.contrib.sessions.middleware.SessionMiddleware',
    'django.middleware.common.CommonMiddleware',
    'django.middleware.csrf.CsrfViewMiddleware',
    'django.contrib.auth.middleware.AuthenticationMiddleware',
    'django.contrib.auth.middleware.SessionAuthenticationMiddleware',
    'django.contrib.messages.middleware.MessageMiddleware',
    'django.middleware.clickjacking.XFrameOptionsMiddleware',
]

ROOT_URLCONF = 'esgf_slcs_server.urls'

TEMPLATES = [
    {
        'BACKEND': 'django.template.backends.django.DjangoTemplates',
        'DIRS': [os.path.join(BASE_DIR, 'esgf_slcs_server', 'templates')],
        'APP_DIRS': True,
        'OPTIONS': {
            'context_processors': [
                'django.template.context_processors.debug',
                'django.template.context_processors.request',
                'django.contrib.auth.context_processors.auth',
                'django.contrib.messages.context_processors.messages',
            ],
        },
    },
]

WSGI_APPLICATION = 'django_wsgi.handler.APPLICATION'


DATABASES = {
    'default': {
        'ENGINE' : os.environ['SLCS_DB_SLCS_ENGINE'],
        'NAME' : os.environ['SLCS_DB_SLCS_NAME'],
        'HOST' : os.environ['SLCS_DB_SLCS_HOST'],
        'PORT' : os.environ['SLCS_DB_SLCS_PORT'],
        'USER' : os.environ['SLCS_DB_SLCS_USER'],
    },
    'userdb' : {
        'ENGINE' : os.environ['SLCS_DB_USER_ENGINE'],
        'NAME' : os.environ['SLCS_DB_USER_NAME'],
        'HOST' : os.environ['SLCS_DB_USER_HOST'],
        'PORT' : os.environ['SLCS_DB_USER_PORT'],
        'USER' : os.environ['SLCS_DB_USER_USER'],
    },
}

ESGF_SLCSDB_PASSWD_FILE = '{0}/conf/db/slcsdb_passwd.txt'.format(APPLICATION_HOME)
with open(ESGF_SLCSDB_PASSWD_FILE) as f:
    DATABASES['default']['PASSWORD'] = f.read().strip()

ESGF_USERDB_PASSWD_FILE = '{0}/conf/db/userdb_passwd.txt'.format(APPLICATION_HOME)
with open(ESGF_USERDB_PASSWD_FILE) as f:
    DATABASES['userdb']['PASSWORD'] = f.read().strip()
ESGF_USERDB_USER_TABLE = os.environ['SLCS_DB_USER_TABLE']
ESGF_USERDB_USER_SCHEMA = os.environ['SLCS_DB_USER_SCHEMA']


AUTH_PASSWORD_VALIDATORS = [
    {
        'NAME': 'django.contrib.auth.password_validation.UserAttributeSimilarityValidator',
    },
    {
        'NAME': 'django.contrib.auth.password_validation.MinimumLengthValidator',
    },
    {
        'NAME': 'django.contrib.auth.password_validation.CommonPasswordValidator',
    },
    {
        'NAME': 'django.contrib.auth.password_validation.NumericPasswordValidator',
    },
]

AUTHENTICATION_BACKENDS = [
    'oauth2_provider.backends.OAuth2Backend',
    'esgf_auth.backend.EsgfUserBackend'
]

LANGUAGE_CODE = 'en-us'

TIME_ZONE = 'UTC'

USE_I18N = True

USE_L10N = True

USE_TZ = True


STATIC_URL = os.environ['SLCS_STATIC_URL']
STATICFILES_DIRS = [os.path.join(BASE_DIR, 'esgf_slcs_server', 'static')]
STATIC_ROOT = os.environ['SLCS_STATIC_ROOT']


# URLs for login/logout
LOGIN_URL = 'accounts_login'
LOGOUT_URL = 'accounts_logout'
LOGIN_REDIRECT_URL = 'home'

BOOTSTRAP3 = {
    'success_css_class': '',
}


# OAuth provider configuration
CERTIFICATE_SCOPE = '{0}/oauth/certificate/'.format(os.environ['SLCS_SERVER_ROOT'])
OAUTH2_PROVIDER = {
    'SCOPES' : {
        CERTIFICATE_SCOPE : 'Obtain short-lived certificate for user',
    },
    'DEFAULT_SCOPES' : [CERTIFICATE_SCOPE],
}

BASIC_AUTH_REALM = 'esgf.llnl.gov'


# Configuration for the Online CA WSGI application
# This is instantiated using the PasteDeploy app_factory, so the configuration below
# corresponds to the global and local configs expected by that function
ONLINECA_PASTEDEPLOY_CONF = 'config:{0}/conf/app/onlineca.ini'.format(APPLICATION_HOME)
ONLINECA_DJANGO_USER_TO_OPENID = 'esgf_auth.openid.django_user_to_openid'
