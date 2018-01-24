# -*- coding: utf-8 -*-
"""
Django settings for the ESGF SLCS Server.
"""

import os

from django_env_settings import *


# Build paths inside the project like this: os.path.join(BASE_DIR, ...)
BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))


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

WSGI_APPLICATION = 'esgf_slcs_server.wsgi.application'

ESGF_USERDB_USER_SCHEMA = os.environ.get('ESGF_USERDB_USER_SCHEMA', 'esgf_security')
ESGF_USERDB_USER_TABLE = os.environ.get('ESGF_USERDB_USER_TABLE', 'user')


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


STATICFILES_DIRS = [os.path.join(BASE_DIR, 'esgf_slcs_server', 'static')]


# URLs for login/logout
LOGIN_URL = 'accounts_login'
LOGOUT_URL = 'accounts_logout'
LOGIN_REDIRECT_URL = 'home'


BOOTSTRAP3 = {
    'success_css_class': '',
}


# OAuth provider configuration
CERTIFICATE_SCOPE = '{}/oauth/certificate/'.format(os.environ['ESGF_SLCS_URL'])
OAUTH2_PROVIDER = {
    'SCOPES' : {
        CERTIFICATE_SCOPE : 'Obtain short-lived certificate for user',
    },
    'DEFAULT_SCOPES' : [CERTIFICATE_SCOPE],
}

BASIC_AUTH_REALM = os.environ['ESGF_SLCS_BASIC_AUTH_REALM']


# Configuration for the Online CA WSGI application
# This is instantiated using the PasteDeploy app_factory, so the configuration below
# corresponds to the global and local configs expected by that function
ONLINECA_PASTEDEPLOY_CONF = 'config:{0}'.format(os.environ['ONLINECA_PASTEDEPLOY_FILE'])
ONLINECA_DJANGO_USER_TO_OPENID = 'esgf_auth.openid.django_user_to_openid'
